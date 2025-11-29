import SwiftUI
import SwiftMath
import SwiftData

struct EquationListView: View {
    @ObservedObject var viewModel: EquationPuzzleViewModel
    @EnvironmentObject var equationStore: EquationStore

    @Environment(\.modelContext) private var context    // ← SwiftData context

    @State private var currentMathString: String = ""
    @State private var isSidebarCollapsed: Bool = false

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
                        canvasHeight: geometry.size.height * 0.18
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding()
            }
        }
    }

    // ==========================================================
    //                     GAME AREA VIEW
    // ==========================================================
    private struct GameAreaView: View {
        @ObservedObject var viewModel: EquationPuzzleViewModel
        @Binding var currentMathString: String
        let canvasHeight: CGFloat
        @State private var isConfirmingLine = false

        var body: some View {
            VStack(spacing: 10){

                if !viewModel.isPuzzleComplete &&
                    viewModel.stars.count > viewModel.currentTargetIndex + 1 {

                    Text("Connect Star \(viewModel.currentTargetIndex + 1) → Star \(viewModel.currentTargetIndex + 2)")
                        .font(.custom("SpaceMono-Regular", size: 30))
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

                MathView(
                    equation: viewModel.currentLatexString,
                    fontSize: 32
                )
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
//                .padding(4)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)

                MathKeyboardView(
                    latexString: $viewModel.currentLatexString,
                    mathString: $currentMathString
                )

                Button {
                    if !isConfirmingLine {
                        viewModel.checkCurrentLineSolution()
                        viewModel.updateUserGraph()
                        isConfirmingLine = true
                    } else {
                        viewModel.checkCurrentLineSolution()
                        viewModel.updateUserGraph()
                        isConfirmingLine = false
                    }
                } label: {
                    Text(isConfirmingLine ? "Confirm Line" : "Check Line")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, minHeight: 10, maxHeight: 20)
                        .padding(10)
                        .background(isConfirmingLine ? Color.blue : Color.white)
                        .foregroundColor(isConfirmingLine ? .white : .black)
                        .cornerRadius(15)
                }
                .disabled(viewModel.isPuzzleComplete)

            }
        }
    }
}
