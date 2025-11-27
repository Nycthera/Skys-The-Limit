import Foundation
import SwiftUI

struct DocFormat: Codable, Identifiable {
    let id: String
    let userid: String
    let equations: [String]?
    let isShared: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let name: String
    let startEndCoords: [String]
}

struct CustomGraphCanvasView: View {

    // Passed from parent
    let stars: [CGPoint]
    let successfulLines: [[(x: Double, y: Double)]]
    let equations: [String]
    let ID: String?
    let name: String?
    let startEndCoords: [String]

    // Local states
    @State private var selectedStarCoordinates: String?
    @State private var selectedStarIndex: Int?

    private let xRange: ClosedRange<Double> = -10...10
    private let yRange: ClosedRange<Double> = -10...10

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ------------------ Canvas Layer ------------------
                Canvas { context, size in

                    let padding: CGFloat = 15 // prevent clipping
                    let xScale = (size.width - 2 * padding) / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = (size.height - 2 * padding) / CGFloat(yRange.upperBound - yRange.lowerBound)

                    context.translateBy(x: size.width / 2, y: size.height / 2)

                    drawGrid(context: context, size: size, xScale: xScale, yScale: yScale, padding: padding)

                    // Draw axes
                    var axes = Path()
                    axes.move(to: CGPoint(x: -size.width/2 + padding, y: 0))
                    axes.addLine(to: CGPoint(x: size.width/2 - padding, y: 0))
                    axes.move(to: CGPoint(x: 0, y: -size.height/2 + padding))
                    axes.addLine(to: CGPoint(x: 0, y: size.height/2 - padding))
                    context.stroke(axes, with: .color(.white.opacity(0.7)), lineWidth: 2)
                    
                    for linePoints in successfulLines {
                            guard let firstPoint = linePoints.first else { continue }

                                var path = Path()
                                path.move(to: scalePoint(firstPoint, xScale, yScale))

                            for point in linePoints.dropFirst() {
                                                path.addLine(to: scalePoint(point, xScale, yScale))
                                            }

                                            context.stroke(
                                                path,
                                                with: .color(.cyan),
                                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                            )
                                        }

                    // ------------------ Draw ONLY the line from startEndCoords ------------------
                    if startEndCoords.count == 2 {
                        // Parse "x,y" into numbers
                        let startParts = startEndCoords[0].split(separator: ",")
                        let endParts = startEndCoords[1].split(separator: ",")

                        if startParts.count == 2, endParts.count == 2,
                           let sx = Double(startParts[0]),
                           let sy = Double(startParts[1]),
                           let ex = Double(endParts[0]),
                           let ey = Double(endParts[1]) {

                            // Scale to canvas space
                            let start = scalePoint((sx, sy), xScale, yScale)
                            let end = scalePoint((ex, ey), xScale, yScale)

                            // Draw yellow line
                            var path = Path()
                            path.move(to: start)
                            path.addLine(to: end)

                            context.stroke(
                                path,
                                with: .color(.yellow),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )

                            // Draw start + end dots
                            let dotRadius: CGFloat = 5

                            context.fill(
                                Circle().path(in: CGRect(
                                    x: start.x - dotRadius,
                                    y: start.y - dotRadius,
                                    width: dotRadius * 2,
                                    height: dotRadius * 2
                                )),
                                with: .color(.white)
                            )

                            context.fill(
                                Circle().path(in: CGRect(
                                    x: end.x - dotRadius,
                                    y: end.y - dotRadius,
                                    width: dotRadius * 2,
                                    height: dotRadius * 2
                                )),
                                with: .color(.white)
                            )
                        }
                    }

                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)

                // ------------------ Name Label ------------------
                if let name {
                    VStack {
                        Text(name)
                            .font(.custom("SpaceMono-Bold", size: 24))
                            .foregroundColor(.yellow)
                            .shadow(radius: 3)
                            .padding(.top, 8)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                }

                // ------------------ Stars Layer (clickable info) ------------------
                ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                    let padding: CGFloat = 15
                    let xScale = (geo.size.width - 2 * padding) / CGFloat(xRange.upperBound - xRange.lowerBound)
                    let yScale = (geo.size.height - 2 * padding) / CGFloat(yRange.upperBound - yRange.lowerBound)
                    let p = scalePoint((Double(star.x), Double(star.y)), xScale, yScale)

                    let screenX = p.x + geo.size.width / 2
                    let screenY = p.y + geo.size.height / 2

                    ZStack {
                        Button {
                            selectedStarIndex = index
                        } label: {
                            Circle()
                                .fill(Color.clear) // removed intermediate white dots
                                .frame(width: 10, height: 10)
                        }

                        if selectedStarIndex == index {
                            Text("(\(Int(star.x)), \(Int(star.y)))")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                                .offset(y: -25)
                        }
                    }
                    .position(x: screenX, y: screenY)
                }
            }
        }
        .onAppear {
            print("CustomGraphCanvasView appeared.")
            print("Equations passed:", equations)
            if let ID {
                print("Document ID:", ID)
            }
        }
    }

    // MARK: - Scale point
    private func scalePoint(_ point: (x: Double, y: Double), _ xScale: CGFloat, _ yScale: CGFloat) -> CGPoint {
        CGPoint(
            x: CGFloat(point.x) * xScale,
            y: -CGFloat(point.y) * yScale
        )
    }

    // MARK: - Draw Grid
    private func drawGrid(context: GraphicsContext, size: CGSize, xScale: CGFloat, yScale: CGFloat, padding: CGFloat) {
        var grid = Path()

        // Vertical lines
        for x in Int(xRange.lowerBound)...Int(xRange.upperBound) {
            let px = CGFloat(x) * xScale
            grid.move(to: CGPoint(x: px, y: -size.height/2 + padding))
            grid.addLine(to: CGPoint(x: px, y: size.height/2 - padding))
        }

        // Horizontal lines
        for y in Int(yRange.lowerBound)...Int(yRange.upperBound) {
            let py = CGFloat(y) * yScale
            grid.move(to: CGPoint(x: -size.width/2 + padding, y: -py))
            grid.addLine(to: CGPoint(x: size.width/2 - padding, y: -py))
        }

        context.stroke(grid, with: .color(.gray.opacity(0.2)), lineWidth: 1)
    }
}
