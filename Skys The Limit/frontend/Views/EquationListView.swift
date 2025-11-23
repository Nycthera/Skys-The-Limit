import SwiftUI
import SwiftMath

struct EquationListView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()
    @EnvironmentObject var equationStore: EquationStore
    
    @State private var currentMathString: String = ""
    @State private var isSidebarCollapsed: Bool = false
    
    // confetti stuff
    @State private var isCelebrating = false
    @State private var goHome = false
    
    // saving constellation
    @State private var showSaveModal = false
    @State private var newConstellationName = ""     // ← FIXED: used as Binding
    
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
                HStack(spacing: 0) {
                    
                    SidebarView(
                        isCollapsed: isSidebarCollapsed,
                        width: geometry.size.width * 0.20,
                        stars: viewModel.stars,
                        successfulEquations: viewModel.successfulEquations
                    )
                    
                    GameAreaView(
                        viewModel: viewModel,
                        currentMathString: $currentMathString,
                        canvasHeight: geometry.size.height * 0.18
                    )
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSidebarCollapsed.toggle()
                            }
                        }) {
                            Image(systemName: "sidebar.left")
                                .font(.system(size: 30))
                                .padding(5)
                                .clipShape(Circle())
                                .padding(.leading, 6)
                        }
                    }
                }
            }
            
            // ==============================
            //        PUZZLE COMPLETE
            // ==============================
            if viewModel.isPuzzleComplete {
                ZStack {
                    ConfettiView(isAnimating: $isCelebrating)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                        .zIndex(10)
                    
                    VStack {
                        Spacer()
                        Text("You Win!")
                            .font(.custom("SpaceMono-Bold", size: 50))
                            .foregroundColor(.yellow)
                            .shadow(radius: 5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isCelebrating = false
                        showSaveModal = true   // show modal
                    }
                    .zIndex(20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .onAppear {
                    DispatchQueue.main.async {
                        isCelebrating = true
                    }
                }
            }
        }
        .sheet(isPresented: $showSaveModal) {
            SaveConstellationModalView(
                isPresented: $showSaveModal,
                equations: $viewModel.successfulEquations,
                constellationName: $newConstellationName,    // ← FIXED BINDING
                docID: nil,
                onSave: {
                    Task {
                        await saveCompletedConstellation()
                        goHome = true
                    }
                },
                onCancel: {
                    goHome = true
                }
            )
        }
    }
    
    // ==========================================================
    //                SAVE TO DATABASE FUNCTION
    // ==========================================================
    func saveCompletedConstellation() async {
        let equationStrings = viewModel.successfulEquations
        
        await post_to_database(
            equations: equationStrings,
            name: newConstellationName   // ← NOW ACTUALLY THE TYPED NAME
        )
    }
    
    
    // ==========================================================
    //                     SIDEBAR VIEW
    // ==========================================================
    private struct SidebarView: View {
        let isCollapsed: Bool
        let width: CGFloat
        let stars: [CGPoint]
        let successfulEquations: [String]
        
        var body: some View {
            VStack(spacing: 12) {
                if !isCollapsed {
                    Text("Equations")
                        .font(.custom("SpaceMono-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    Text("Target Coordinates")
                        .font(.custom("SpaceMono-Bold", size: 18))
                        .foregroundColor(.yellow)
                    
                    ForEach(Array(stars.enumerated()), id: \.offset) { index, star in
                        Text("Star \(index + 1): (\(Int(star.x)), \(Int(star.y)))")
                            .font(.custom("SpaceMono-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(5)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(successfulEquations, id: \.self) { equation in
                                MathView(
                                    equation: equation,
                                    textAlignment: .left,
                                    fontSize: 22
                                )
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            .padding(.trailing, 8)
            .frame(width: isCollapsed ? 0 : width)
            .clipped()
            .background(isCollapsed ? Color.clear : Color.black.opacity(0.4))
            .animation(.easeInOut, value: isCollapsed)
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
            VStack(spacing: 15) {
                
                if !viewModel.isPuzzleComplete &&
                    viewModel.stars.count > viewModel.currentTargetIndex + 1 {
                    
                    Text("Connect Star \(viewModel.currentTargetIndex + 1) → Star \(viewModel.currentTargetIndex + 2)")
                        .font(.custom("SpaceMono-Regular", size: 20))
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
                    fontSize: 22
                )
                .frame(maxWidth: .infinity, minHeight: 10, maxHeight: 20)
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
                        .font(.custom("SpaceMono-Regular", size: 20))
                        .frame(maxWidth: .infinity, minHeight: 10, maxHeight: 20)
                        .padding(.vertical, 15)
                        .padding(.bottom, 50)
                        .background(isConfirmingLine ? Color.blue : Color.white)
                        .foregroundColor(isConfirmingLine ? .white : .black)
                        .cornerRadius(15)
                }
                .disabled(viewModel.isPuzzleComplete)
            }
        }
    }
}
