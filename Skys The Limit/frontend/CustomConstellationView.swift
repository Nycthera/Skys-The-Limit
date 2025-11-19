//
//  CustomConstellationView.swift
//  Skys The Limit
//
//  Created by Chris  on 19/11/25.
//

import SwiftUI
import SwiftMath

struct DocumentFormat: Codable, Identifiable {
    let id: String
    let userid: String
    let equations: [String]?
    let isShared: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let name: String
}

struct CustomConstellationView: View {
    
    @State private var selectedStarCoordinates: String? = nil
    @State private var selectedStarIndex: Int? = nil
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []
    
    @State private var numberOfStars: Int = 0
    
    let currentLine: [(x: Double, y: Double)] = []
    let currentTargetIndex: Int = 0
    let connectedStarIndices: Set<Int> = []
    let ID: String
    
    private let xRange: ClosedRange<Double> = -10...10
    private let yRange: ClosedRange<Double> = -10...10
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                
                context.translateBy(x: size.width / 2, y: size.height / 2)
                
                drawGrid(context: context, size: size, xScale: xScale, yScale: yScale)
                
                // Axes
                var axes = Path()
                axes.move(to: CGPoint(x: -size.width/2, y: 0))
                axes.addLine(to: CGPoint(x: size.width/2, y: 0))
                axes.move(to: CGPoint(x: 0, y: -size.height/2))
                axes.addLine(to: CGPoint(x: 0, y: size.height/2))
                context.stroke(axes, with: .color(.white.opacity(0.7)), lineWidth: 2)
                
                // Completed lines
                for (lineIndex, line) in successfulLines.enumerated() {
                    guard let first = line.first else { continue }
                    guard lineIndex + 1 < stars.count else { continue }
                    
                    let starA = stars[lineIndex]
                    let starB = stars[lineIndex + 1]
                    
                    let minX = min(starA.x, starB.x)
                    let maxX = max(starA.x, starB.x)
                    let minY = min(starA.y, starB.y)
                    let maxY = max(starA.y, starB.y)
                    
                    let filteredLine = line.filter { point in
                        (minX...maxX).contains(point.x) && (minY...maxY).contains(point.y)
                    }
                    
                    if !filteredLine.isEmpty {
                        var path = Path()
                        path.move(to: scalePoint(filteredLine.first!, xScale: xScale, yScale: yScale))
                        for point in filteredLine.dropFirst() {
                            path.addLine(to: scalePoint(point, xScale: xScale, yScale: yScale))
                        }
                        context.stroke(path,
                                       with: .color(.cyan),
                                       style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                }
                
                // Current preview line
                if let first = currentLine.first {
                    var path = Path()
                    path.move(to: scalePoint(first, xScale: xScale, yScale: yScale))
                    for point in currentLine.dropFirst() {
                        path.addLine(to: scalePoint(point, xScale: xScale, yScale: yScale))
                    }
                    context.stroke(path,
                                   with: .color(.white.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6]))
                }
            }
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            
            // Stars overlay
            GeometryReader { geo in
                let xScale = geo.size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                let yScale = geo.size.height / CGFloat(yRange.upperBound - yRange.lowerBound)
                
                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale: xScale, yScale: yScale)
                    let screenX = p.x + geo.size.width / 2
                    let screenY = p.y + geo.size.height / 2
                    
                    ZStack {
                        Button(action: {
                            selectedStarIndex = index
                        }) {
                            Circle()
                                .fill(
                                    connectedStarIndices.contains(index) ? Color.blue :
                                        (index == currentTargetIndex || index == currentTargetIndex + 1
                                         ? Color.yellow
                                         : Color.white.opacity(0.7))
                                )
                                .frame(width: 10, height: 10)
                        }
                        
                        if selectedStarIndex == index {
                            Text("(\(Int(star.x)), \(Int(star.y)))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(6)
                                .offset(y: -25)
                        }
                    }
                    .position(x: screenX, y: screenY)
                }
            }
        }
        .onAppear {
            Task {
                if let document: Constellation = await get_document_for_user(rowId: ID) {
                    self.arrayOfEquations = document.equations ?? []
                    self.numberOfStars = self.arrayOfEquations.count
                    
                    var allPoints: [(x: Double, y: Double)] = []
                    for eqStr in self.arrayOfEquations {
                        let engine = MathEngine(equation: eqStr)
                        let points = engine.evaluate() ?? []
                        allPoints.append(contentsOf: points)
                    }
                    
                    self.stars = allPoints.map { CGPoint(x: $0.x, y: $0.y) }
                    self.successfulLines = allPoints.chunked(into: 2)
                }
            }
        }
        
    }
    
    // MARK: - Helpers
    
    private func scalePoint(_ point: (x: Double, y: Double), xScale: CGFloat, yScale: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(point.x) * xScale,
                y: -CGFloat(point.y) * yScale)
    }
    
    private func drawGrid(context: GraphicsContext, size: CGSize, xScale: CGFloat, yScale: CGFloat) {
        var grid = Path()
        for x in Int(xRange.lowerBound)...Int(xRange.upperBound) {
            let px = CGFloat(x) * xScale
            grid.move(to: CGPoint(x: px, y: -size.height/2))
            grid.addLine(to: CGPoint(x: px, y: size.height/2))
        }
        for y in Int(yRange.lowerBound)...Int(yRange.upperBound) {
            let py = CGFloat(y) * yScale
            grid.move(to: CGPoint(x: -size.width/2, y: -py))
            grid.addLine(to: CGPoint(x: size.width/2, y: -py))
        }
        context.stroke(grid, with: .color(.gray.opacity(0.2)), lineWidth: 1)
    }
}

