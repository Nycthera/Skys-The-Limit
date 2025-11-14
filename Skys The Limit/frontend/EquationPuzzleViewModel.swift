import Foundation
import CoreGraphics
import Combine

@MainActor
class EquationPuzzleViewModel: ObservableObject {
    // --- Puzzle State ---
    @Published var stars: [CGPoint] = []
    @Published var successfulLines: [[(x: Double, y: Double)]] = []
    @Published var successfulEquations: [String] = [] // THIS IS THE MISSING LINE
    
    // --- User Input State ---
    @Published var currentLatexString: String = "y="
    @Published var currentGraphPoints: [(x: Double, y: Double)] = []
    
    // --- Game Flow State ---
    @Published var currentTargetIndex: Int = 0
    @Published var isPuzzleComplete: Bool = false
    @Published var feedbackMessage: String = ""

    init() {
        generateNewPuzzle()
    }
    
    func generateNewPuzzle(starCount: Int = 4) {
        stars.removeAll()
        successfulLines.removeAll()
        successfulEquations.removeAll() // Clear the new array
        currentTargetIndex = 0
        isPuzzleComplete = false
        resetCurrentLine()
        
        var usedPoints = Set<CGPoint>()
        for _ in 0..<starCount {
            var newPoint: CGPoint
            repeat {
                newPoint = CGPoint(x: Int.random(in: -8...8), y: Int.random(in: -8...8))
            } while usedPoints.contains(newPoint)
            stars.append(newPoint)
            usedPoints.insert(newPoint)
        }
    }
    
    func updateUserGraph() {
        let engine = MathEngine(equation: currentLatexString)
        self.currentGraphPoints = engine.calculatePoints()
    }
    
    func checkCurrentLineSolution() {
        guard stars.count > currentTargetIndex + 1 else { return }
        
        let starA = stars[currentTargetIndex]
        let starB = stars[currentTargetIndex + 1]
        let tolerance = 0.5
        
        let connectsStarA = lineContainsPoint(line: currentGraphPoints, point: starA, tolerance: tolerance)
        let connectsStarB = lineContainsPoint(line: currentGraphPoints, point: starB, tolerance: tolerance)
        
        if connectsStarA && connectsStarB {
            // Save both the points and the equation string
            successfulLines.append(currentGraphPoints)
            successfulEquations.append(currentLatexString) // Save the successful equation
            
            currentTargetIndex += 1
            
            if currentTargetIndex >= stars.count - 1 {
                isPuzzleComplete = true
                feedbackMessage = "Constellation Complete!"
            } else {
                feedbackMessage = "Success! Now connect the next pair."
            }
            resetCurrentLine()
            
        } else {
            feedbackMessage = "Not quite! Try a different equation."
        }
    }
    
    private func resetCurrentLine() {
        currentLatexString = "y="
        currentGraphPoints.removeAll()
    }
    
    private func lineContainsPoint(line: [(x: Double, y: Double)], point: CGPoint, tolerance: Double) -> Bool {
        return line.contains { linePoint in
            let dx = linePoint.x - point.x
            let dy = linePoint.y - point.y
            return sqrt(dx*dx + dy*dy) < tolerance
        }
    }
}
