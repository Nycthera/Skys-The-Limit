//
//  GraphCanvasView.swift
//  Skys The Limit
//
//  Created by Nhavin Thirukkumaran on 7/11/25.
//

import SwiftUI
import SwiftMath
import Foundation // Ns expression lives in here

private func calculatePoints(for expressionString: String, size: CGSize) -> [CGPoint] {
    var points: [CGPoint] = []
    
    // 1. Create the NSExpression object from the user's string.
    // Note: It doesn't handle implicit multiplication like "2x", you need "2*x".
    // It also doesn't use "^" for power, it uses "**".
 
    let expression = NSExpression(format: expressionString)
    
    let xMin: Double = -10
    let xMax: Double = 10
    
    for screenX in 0...Int(size.width) {
        let mathX = xMin + (Double(screenX) / size.width) * (xMax - xMin)
        
        // 2. Create a dictionary to substitute our 'x' variable.
        let context: [String: Any] = ["x": mathX]
        
        // 3. Evaluate the expression.
        // We need to check if the result is a valid number.
        if let result = expression.expressionValue(with: nil, context: context as? NSMutableDictionary) as? Double {
            let mathY = result
            
            // Translate mathY to screenY...
            let screenY = size.height - (CGFloat(mathY) * (size.height / 20))
            points.append(CGPoint(x: CGFloat(screenX), y: screenY))
        }
    }
    
    return points
}





