import SwiftUI
import SwiftMath
import SwiftData

struct EquationListView: View {
    @ObservedObject var viewModel: EquationPuzzleViewModel
    @EnvironmentObject var equationStore: EquationStore
    
    @Environment(\.modelContext) private var context    // ← SwiftData context
    
    @State private var currentMathString: String = ""
    
    // confetti stuff
    @State private var isCelebrating = false
    @State private var goHome = false
    
    // saving constellation
    @State private var showSaveModal = false
    @State private var newConstellationName = ""
    
    var body: some View {
        ZStack {
            
            // HIDDEN NAV LINK TO HOME
            NavigationLink(destination: MainMenuView(), isActive: $goHome) {
                EmptyView()
            }
            .hidden()
            GeometryReader { geometry in
                GameAreaView(
                    viewModel: viewModel,
                    currentMathString: $currentMathString,
                    canvasHeight: geometry.size.height * 0.20
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(
                Image("Space")
                    .resizable()
                    .scaledToFill()
                    .backgroundExtensionEffect()
            )
        }
    }
    
    // ==========================================================
    //                     GAME AREA VIEW
    // ==========================================================
    private struct GameAreaView: View {
        @State private var showToast = false
        @State private var toastMessage = ""

        @ObservedObject var viewModel: EquationPuzzleViewModel
        @Binding var currentMathString: String
        let canvasHeight: CGFloat
        
        @State private var isConfirmingLine = false

        var body: some View {
            VStack(spacing: 14) {

                // TITLE
                if !viewModel.isPuzzleComplete &&
                    viewModel.stars.count > viewModel.currentTargetIndex + 1 {

                    Text("Connect Star \(viewModel.currentTargetIndex + 1) → Star \(viewModel.currentTargetIndex + 2)")
                        .foregroundColor(.white)
                }

                // CANVAS
                GraphCanvasView(
                    stars: viewModel.stars,
                    successfulLines: viewModel.successfulLines,
                    currentLine: viewModel.currentGraphPoints,
                    currentTargetIndex: viewModel.currentTargetIndex,
                    connectedStarIndices: viewModel.connectedStarIndices
                )

                // CURRENT LATEX DISPLAY
                MathView(
                    equation: viewModel.currentLatexString,
                    fontSize: 31
                )
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 42)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                // KEYBOARD + BUTTON (aligned)
                VStack(spacing: 25) {

                    // KEYBOARD
                    MathKeyboardView(
                        latexString: $viewModel.currentLatexString,
                        mathString: $currentMathString
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)

                    // ============================
                    //      FIXED DRAW LINE BUTTON
                    // ============================
                    Button {
                        let previousIndex = viewModel.currentTargetIndex
                        
                        // Only checks correctness — does NOT update graph
                        viewModel.checkCurrentLineSolution()
                        
                        let success = viewModel.currentTargetIndex > previousIndex

                        if success {
                            // Only update graph when correct
                            viewModel.updateUserGraph()

                        } else {

                            // If you do NOT want wrong lines drawn, comment out:
                            viewModel.updateUserGraph()

                            toastMessage = "Wrong Equation!"
                            showToast = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }

                    } label: {
                        Text("Draw Line")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .cornerRadius(15)
                    }
                    .disabled(viewModel.isPuzzleComplete)
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal, 20)
                    // ============================

                } // VStack

            } // main VStack
            .overlay(alignment: .top) {
                if showToast {
                    Text(toastMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(.red.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.top, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showToast)
        }
    }

}
