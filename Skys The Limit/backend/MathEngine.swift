//
//  MathEngine.swift
//  Skys The Limit
//
//  Created by Chris on 7/11/25.
//

import Foundation

enum EquationType: String {
    case linear = "Linear"
    case quadratic = "Quadratic"
    case trigonometric = "Trigonometric"
    case exponential = "Exponential"
    case logarithmic = "Logarithmic"
    case constant = "Constant"
    case unknown = "Unknown"
}

final class MathEngine {

    // Raw equation string from user
    var equation: String
    
    // Default numeric values for symbolic coefficients
    var coefficients: [String: Double] = [
        "a": 1, "b": 1, "c": 1,
        "m": 1, "n": 1
    ]

    // Characters or patterns that can cause NSExpression(format:) to throw Obj-C exceptions
    private let disallowedExpressionCharacters = CharacterSet(charactersIn: "\"|")

    // Ensure the expression is safe for NSExpression. Returns nil if unsafe.
    private func makeSafeExpressionString(_ input: String) -> String? {
        // Reject if any disallowed characters are present
        if input.rangeOfCharacter(from: disallowedExpressionCharacters) != nil {
            return nil
        }
        // Reject if there is any '=' remaining (we only evaluate RHS of y=...)
        if input.contains("=") { return nil }

        // Basic sanity: must contain only allowed tokens for math evaluation
        // (same as isValid, but without '=')
        let validPattern = "^[0-9a-zA-Z\\^\\+\\-\\*\\/\\(\\)\\.]+$"
        if input.range(of: validPattern, options: .regularExpression) == nil {
            return nil
        }
        return input
    }

    init(equation: String) {
        self.equation = equation.replacingOccurrences(of: " ", with: "")
    }

    // ------------------------------------------------------------
    // MARK: - Detect Equation Type
    // ------------------------------------------------------------
    func detectType() -> EquationType {
        let eq = strippedEquation()

        if eq.range(of: #"sin|cos|tan"#, options: .regularExpression) != nil {
            return .trigonometric
        }
        if eq.range(of: #"e\^|exp"#, options: .regularExpression) != nil {
            return .exponential
        }
        if eq.range(of: #"log|ln"#, options: .regularExpression) != nil {
            return .logarithmic
        }
        if eq.range(of: #"[xy]\^2"#, options: .regularExpression) != nil {
            return .quadratic
        }
        if eq.range(of: #"[xy]"#, options: .regularExpression) != nil {
            return .linear
        }
        if eq.range(of: #"^[0-9\.\-]+$"#, options: .regularExpression) != nil {
            return .constant
        }

        return .unknown
    }

    // Remove "y=" at start
    private func strippedEquation() -> String {
        equation.replacingOccurrences(of: #"^[a-zA-Z]\s*="#,
                                      with: "",
                                      options: .regularExpression)
    }

    // ------------------------------------------------------------
    // MARK: - Validate equation
    // ------------------------------------------------------------
    func isValid() -> Bool {
        // Allowed characters
        let validPattern = #"^[0-9a-zA-Z\^\+\-\*\/\(\)\.\=]+$"#
        return equation.range(of: validPattern, options: .regularExpression) != nil
    }

    // ------------------------------------------------------------
    // MARK: - Preprocess (replace coefficients, handle ^, fix multiplication)
    // ------------------------------------------------------------
    private func preprocessEquation() -> String {
        var eq = strippedEquation()

        // If user entered an equality accidentally like "x+1==1" or additional parts, keep only the leftmost segment before '='
        if let eqIndex = eq.firstIndex(of: "=") {
            eq = String(eq[..<eqIndex])
        }

        // Strip any stray double quotes or pipes proactively to avoid NSExpression crashes
        eq.removeAll { ch in
            ch == "\"" || ch == "|" }

        // ---- Replace coefficients a,b,c,m,n safely ----
        for (symbol, value) in coefficients {
            // Only replace standalone a, b, c (NOT inside sin/tan/log)
            let pattern = "(?<![a-zA-Z])\(symbol)(?![a-zA-Z])"
            eq = eq.replacingOccurrences(
                of: pattern,
                with: "(\(value))",
                options: .regularExpression
            )
        }

        // ---- Convert ^ into pow() ----
        // Match x^2, (x+1)^3, 2^x etc.
        let powerPattern = #"([a-zA-Z0-9\)\(]+)\^([a-zA-Z0-9\)\(]+)"#
        let regex = try! NSRegularExpression(pattern: powerPattern)

        while let match = regex.firstMatch(in: eq, range: NSRange(eq.startIndex..., in: eq)) {
            let baseRange = Range(match.range(at: 1), in: eq)!
            let expRange = Range(match.range(at: 2), in: eq)!

            let base = eq[baseRange]
            let exp  = eq[expRange]
            let replacement = "pow(\(base),\(exp))"

            let fullRange = baseRange.lowerBound..<expRange.upperBound
            eq.replaceSubrange(fullRange, with: replacement)
        }

        // ---- 2x → 2*x, (1)x → (1)*x ----
        eq = eq.replacingOccurrences(
            of: #"([0-9\)])x"#,
            with: "$1*x",
            options: .regularExpression
        )

        // ---- x( → x*( ----
        eq = eq.replacingOccurrences(
            of: #"x\("#,
            with: "x*(",
            options: .regularExpression
        )

        return eq
    }

    // ------------------------------------------------------------
    // MARK: - Calculate points
    // ------------------------------------------------------------
    func calculatePoints(
        xRange: ClosedRange<Double> = -10...10,
        step: Double = 1.0
    ) -> [(x: Double, y: Double)] {
        
        var result: [(x: Double, y: Double)] = []
        let processed = preprocessEquation()

        for x in stride(from: xRange.lowerBound, through: xRange.upperBound, by: step) {
            let exprString = processed.replacingOccurrences(of: "x", with: "(\(x))")

            // Debug print (super useful)
            print("EXPR:", exprString)

            // Build a safe expression string before constructing NSExpression (which crashes on bad formats)
            guard let safeExpr = makeSafeExpressionString(exprString) else {
                // Skip this x if the expression would be unsafe
                continue
            }

            let expr = NSExpression(format: safeExpr)
            if let y = expr.expressionValue(with: nil, context: nil) as? Double, y.isFinite {
                result.append((x, y))
            }
        }

        return result
    }

    // ------------------------------------------------------------
    // MARK: - Evaluate equation
    // ------------------------------------------------------------
    func evaluate() -> [(x: Double, y: Double)]? {
        guard isValid() else {
            print("Invalid equation format!")
            return nil
        }

        let type = detectType()
        print("Equation Type:", type.rawValue)

        return calculatePoints()
    }
}

