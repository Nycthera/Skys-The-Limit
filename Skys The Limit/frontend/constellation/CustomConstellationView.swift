import SwiftUI
import SwiftMath

struct CustomConstellationView: View {
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int? = nil
    @State private var isSidebarCollapsed = false
    @State private var showSaveModal = false
    @State private var constellationName: String = ""
    @State private var startEndCoords: [String] = [""]
    
    
    @Environment(\.presentationMode) var presentationMode
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

                        VStack(spacing: 25) {
                            CustomGraphCanvasView(
                                stars: stars,
                                successfulLines: successfulLines,
                                equations: arrayOfEquations,
                                ID: ID,
                                name: constellationName,
                                startEndCoords: startEndCoords
                            )
                            .frame(height: geo.size.height * 0.9)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(12)
                            .layoutPriority(1)
                        }
                        .padding()
                        .frame(width: geo.size.width - (isSidebarCollapsed ? 0 : sidebarWidth))
                        .frame(maxHeight: .infinity, alignment: .top)
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
                        .font(.custom("SpaceMono-Regular", size: 18))
                        .padding(5)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .onAppear {
                Task {
                    if let doc = await getDocumentForUser(rowId: ID) {
                        self.arrayOfEquations = doc.equations
                        self.constellationName = doc.name
                        self.startEndCoords = doc.startEndCords
                        print("Loaded name:", doc.name)
                        print("cords", doc.startEndCords)
                    }
                }
            }
            .onChange(of: arrayOfEquations) { _ in
                updateStarsFromEquations()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Update stars from equations
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
