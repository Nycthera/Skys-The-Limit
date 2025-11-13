import SwiftUI

struct EquationListView: View {
    // This view is now powered by our puzzle game logic.
    @StateObject private var viewModel = EquationPuzzleViewModel()

    var body: some View {
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // Instructions for the user
                if !viewModel.isPuzzleComplete && viewModel.stars.count > viewModel.currentTargetIndex + 1 {
                    Text("Connect Star \(viewModel.currentTargetIndex + 1) to Star \(viewModel.currentTargetIndex + 2)")
                        .font(.custom("SpaceMono-Regular", size: 20))
                        .foregroundColor(.yellow)
                        .padding(.vertical, 5)
                        .transition(.opacity)
                }
                
                // The upgraded canvas that shows the full game state
                GraphCanvasView(
                    stars: viewModel.stars,
                    successfulLines: viewModel.successfulLines,
                    currentLine: viewModel.currentGraphPoints,
                    currentTargetIndex: viewModel.currentTargetIndex
                )
                .frame(height: 300)

                MathView(equation: viewModel.currentLatexString, fontSize: 30)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)

                MathKeyboardView(latexString: $viewModel.currentLatexString)
                
                Button("Check Line") {
                    viewModel.checkCurrentLineSolution()
                }
                .font(.custom("SpaceMono-Regular", size: 20))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(15)
                .disabled(viewModel.isPuzzleComplete)
            }
            .padding()
            
            // Overlay for when the puzzle is complete
            if viewModel.isPuzzleComplete {
                VStack(spacing: 20) {
                    Text("Constellation Complete!")
                        .font(.custom("SpaceMono-Bold", size: 32))
                        .foregroundColor(.green)
                    Button("Create New Puzzle") {
                        viewModel.generateNewPuzzle()
                    }
                    .font(.custom("SpaceMono-Regular", size: 20))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(40)
                .background(.black.opacity(0.85))
                .cornerRadius(20)
                .transition(.scale)
            }
        }
        .animation(.default, value: viewModel.isPuzzleComplete)
        .animation(.default, value: viewModel.currentTargetIndex)
        .onChange(of: viewModel.currentLatexString) { _ in
            viewModel.updateUserGraph()
        }
        .navigationTitle("Draw The Stars")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Draw The Stars")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
    }
}
