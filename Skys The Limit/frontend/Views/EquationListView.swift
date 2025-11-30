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

            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                    GameAreaView(
                        viewModel: viewModel,
                        currentMathString: $currentMathString,
                        canvasHeight: geometry.size.height * 0.25
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
            VStack(spacing: 10){

                if !viewModel.isPuzzleComplete &&
                    viewModel.stars.count > viewModel.currentTargetIndex + 1 {

                    Text("Connect Star \(viewModel.currentTargetIndex + 1) → Star \(viewModel.currentTargetIndex + 2)")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }

                GraphCanvasView(
                    stars: viewModel.stars,
                    successfulLines: viewModel.successfulLines,
                    currentLine: viewModel.currentGraphPoints,
                    currentTargetIndex: viewModel.currentTargetIndex,
                    connectedStarIndices: viewModel.connectedStarIndices
                )
                .frame(height: canvasHeight)
//                .frame(height: geo.size.height * 0.5)
                
                MathView(
                    equation: viewModel.currentLatexString,
                    fontSize: 31
                )
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)

                MathKeyboardView(
                    latexString: $viewModel.currentLatexString,
                    mathString: $currentMathString
                )

                Button {
                    let previousIndex = viewModel.currentTargetIndex
                    
                    viewModel.checkCurrentLineSolution()

                    let success = viewModel.currentTargetIndex > previousIndex

                    if !success {
                        viewModel.updateUserGraph()
                        showToast = true
                        toastMessage = "Wrong Equation!"

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showToast = false
                        }
                    } else {
                        viewModel.updateUserGraph()
                    }

                } label: {
                    Text("Draw Line")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .disabled(viewModel.isPuzzleComplete)
            }
            
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
