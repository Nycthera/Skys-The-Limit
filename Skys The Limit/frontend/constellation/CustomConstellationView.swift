import SwiftUI
import SwiftData
import SwiftMath

struct CustomConstellationView: View {
    // MARK: - State
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int?

    @State private var isSidebarCollapsed = false
    @State private var showSaveModal = false

    @State private var constellationName: String = ""
    @State private var startEndCoords: [String] = [""]

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context

    let ID: String
    private let sidebarWidth: CGFloat = 250

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Image("Space")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    HStack(spacing: 0) {
                        CustomSidebarView(
                            isCollapsed: isSidebarCollapsed,
                            equations: $arrayOfEquations,
                            editingString: $editingLatexString,
                            editingIndex: $editingIndex
                        )

                        ScrollView {
                            VStack(spacing: 15) {
                                CustomGraphCanvasView(
                                    stars: stars,
                                    successfulLines: successfulLines,
                                    equations: arrayOfEquations,
                                    ID: ID,
                                    name: constellationName,
                                    startEndCoords: startEndCoords
                                )
                                .frame(height: geo.size.height * 0.5)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(12)

                                VStack(alignment: .leading) {
                                    Text("y = \(editingLatexString)")
                                        .font(.system(size: 32))
                                        .foregroundColor(.yellow)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                }

                                MathKeyboardView(
                                    latexString: $editingLatexString,
                                    mathString: $editingMathString
                                )
                                .fixedSize(horizontal: false, vertical: true)

                                Button {
                                    guard !editingMathString.isEmpty else { return }

                                    if let index = editingIndex {
                                        arrayOfEquations[index] = editingMathString
                                    } else {
                                        arrayOfEquations.append(editingMathString)
                                    }

                                    editingLatexString = ""
                                    editingMathString = ""
                                    editingIndex = nil
                                } label: {
                                    Text(editingIndex != nil ? "Update Equation" : "Add Equation")
                                        .font(.title)
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(15)
                                }
                            }
                            .padding()
                            .frame(width: geo.size.width - (isSidebarCollapsed ? 0 : sidebarWidth))
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut) { isSidebarCollapsed.toggle() }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button { showSaveModal = true } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Button("Back") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .padding(5)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .onAppear {
                loadConstellation()
            }
            .onChange(of: arrayOfEquations) { _ in
                updateStarsFromEquations()
            }
        }
        .sheet(isPresented: $showSaveModal) {
            SaveConstellationModalView(
                isPresented: $showSaveModal,
                equations: $arrayOfEquations,
                constellationName: $constellationName,
                startEndCords: $startEndCoords,
                docID: ID,
                onSave: {
                    saveConstellation()
                    showSaveModal = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Load from SwiftData
    private func loadConstellation() {
        let service = ConstellationDataService(context: context)
        if let constellation = service.fetchConstellations(userId: UIDevice.current.identifierForVendor!.uuidString)
            .first(where: { $0.id == ID }) {
            arrayOfEquations = constellation.equations
            constellationName = constellation.name
            startEndCoords = constellation.startEndCords
        }
    }

    // MARK: - Save to SwiftData
    private func saveConstellation() {
        let service = ConstellationDataService(context: context)
        let equationsWithY = arrayOfEquations.map { $0.starts(with: "y =") ? $0 : "y = \($0)" }

        if let constellation = service.fetchConstellations(userId: UIDevice.current.identifierForVendor!.uuidString)
            .first(where: { $0.id == ID }) {
            service.updateConstellation(
                constellation: constellation,
                newName: constellationName,
                newEquations: equationsWithY,
                newStartEndCords: startEndCoords
            )
        }
    }

    // MARK: - Star Update
    private func updateStarsFromEquations() {
        stars = []
        successfulLines = []

        for eq in arrayOfEquations {
            let engine = MathEngine(equation: eq)
            guard let points = engine.evaluate(), !points.isEmpty else { continue }

            stars.append(contentsOf: points.map { CGPoint(x: $0.x, y: $0.y) })
            successfulLines.append(points)
        }
    }

    // MARK: - Sidebar
    private struct CustomSidebarView: View {
        let isCollapsed: Bool
        @Binding var equations: [String]
        @Binding var editingString: String
        @Binding var editingIndex: Int?

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if !isCollapsed {
                    Text("Equations")
                        .font(.custom("SpaceMono-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(equations.indices, id: \.self) { idx in
                                MathView(
                                    equation: equations[idx],
                                    textAlignment: .left,
                                    fontSize: 20
                                )
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .onTapGesture {
                                    editingString = equations[idx]
                                    editingIndex = idx
                                }
                                .onLongPressGesture {
                                    withAnimation {
                                        equations.remove(at: idx)
                                        if editingIndex == idx {
                                            editingString = ""
                                            editingIndex = nil
                                        } else if let current = editingIndex, current > idx {
                                            editingIndex = current - 1
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }

                Spacer()
            }
            .frame(width: isCollapsed ? 0 : 250)
            .clipped()
            .background(isCollapsed ? Color.clear : Color.black.opacity(0.4))
        }
    }
}
