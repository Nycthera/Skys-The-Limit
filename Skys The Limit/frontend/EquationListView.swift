import SwiftUI
import SwiftMath

struct EquationListView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            // Main Horizontal Layout
            HStack(spacing: 15) {
                
                // --- LEFT COLUMN: Equations List ---
                VStack(spacing: 10) {
                    Text("Equations")
                        .font(.custom("SpaceMono-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.successfulEquations, id: \.self) { equation in
                                MathView(equation: equation, textAlignment: .left, fontSize: 22)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(15)
                // --- FIX 1: Give the left column a fixed width ---
                // .frame(width: 300)

                // --- RIGHT COLUMN: Interactive Area ---
                VStack(spacing: 15) {
                    if !viewModel.isPuzzleComplete && viewModel.stars.count > viewModel.currentTargetIndex + 1 {
                        Text("Connect Star \(viewModel.currentTargetIndex + 1) to Star \(viewModel.currentTargetIndex + 2)")
                            .font(.custom("SpaceMono-Regular", size: 20))
                            .foregroundColor(.yellow)
                            .padding(.vertical, 5)
                    }
                    
                    GraphCanvasView(
                        stars: viewModel.stars,
                        successfulLines: viewModel.successfulLines,
                        currentLine: viewModel.currentGraphPoints,
                        currentTargetIndex: viewModel.currentTargetIndex
                    )
                    // --- FIX 2: Constrain the graph's height ---
                    // This tells the graph to use the available vertical space,
                    // but no more. This keeps it from pushing other views down.
                    .frame(maxHeight: .infinity)
                    
                    MathView(equation: viewModel.currentLatexString, fontSize: 22)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)

                    MathKeyboardView(latexString: $viewModel.currentLatexString)
                      //  .frame(height: 240) // The keyboard has a fixed height
                    
                    Button("Check Line") {
                        viewModel.checkCurrentLineSolution()
                    }
                    .font(.custom("SpaceMono-Regular", size: 20))
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                }
                // --- FIX 3: Tell the right column to fill the remaining space ---
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // Puzzle Complete Overlay
            if viewModel.isPuzzleComplete {
                // ... (Overlay code remains the same)
            }
        }
        .animation(.default, value: viewModel.isPuzzleComplete)
        .animation(.default, value: viewModel.currentTargetIndex)
        .onChange(of: viewModel.currentLatexString) { _ in
            viewModel.updateUserGraph()
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { /* ... (Toolbar code remains the same) ... */ }
    }
}
