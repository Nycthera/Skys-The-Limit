import SwiftUI
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
    let ID: String
    private let sidebarWidth: CGFloat = 250
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Image("Space")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    HStack(spacing: 0) {
                        // Sidebar
                        CustomSidebarView(
                            isCollapsed: isSidebarCollapsed,
                            equations: $arrayOfEquations,
                            editingString: $editingLatexString,
                            editingIndex: $editingIndex
                        )
                        
                        // Main content
                        ScrollView {
                            VStack(spacing: 25) {
                                // Canvas
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
                                
                                // Current input
                                VStack(alignment: .leading) {
                                    Text("y = \(editingLatexString)")
                                        .font(.custom("SpaceMono-Regular", size: 24))
                                        .foregroundColor(.yellow)
                                        .padding(3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                // Keyboard
                                MathKeyboardView(
                                    latexString: $editingLatexString,
                                    mathString: $editingMathString
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                
                                // Add / Update button
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
                                        .font(.custom("SpaceMono-Regular", size: 20))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
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
            
            // Navigation bar
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
                        // Save
                        Button { showSaveModal = true } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Back
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
            
            // Load document
            .onAppear {
                Task {
                    if let doc = await getDocumentForUser(rowId: ID) {
                        arrayOfEquations = doc.equations
                        constellationName = doc.name
                        startEndCoords = doc.startEndCords
                    }
                }
            }
            .onChange(of: arrayOfEquations) { _ in
                updateStarsFromEquations()
            }
        }
        
        // Save modal
        .sheet(isPresented: $showSaveModal) {
            SaveConstellationModalView(
                isPresented: $showSaveModal,
                equations: $arrayOfEquations,
                constellationName: $constellationName,
                startEndCords: $startEndCoords,
                docID: ID,
                onSave: {
                    Task {
                        await saveToAppwrite()
                        // Dismiss modal and then return to home
                        showSaveModal = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        
        .navigationViewStyle(.stack)
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
    
    // MARK: - Save to Appwrite (with y= prefix)
    private func saveToAppwrite() async {
        do {
            // Add 'y = ' to each equation before saving
            let equationsWithY = arrayOfEquations.map { eq in
                eq.starts(with: "y =") ? eq : "y = \(eq)"
            }
            
            try await updateUserDocument(
                id: ID,
                name: constellationName,
                equations: equationsWithY,
                startEndCoords: startEndCoords
            )
            print("Saved successfully with y= prefix")
        } catch {
            print("❌ Error saving:", error)
        }
    }
    
    // MARK: - Update document wrapper (unchanged)
    private func updateUserDocument(id: String, name: String, equations: [String], startEndCoords: [String], isShared: Bool = false) async throws {
        let parameters = AppwriteFunctionsParameters(
            id: id,
            userId: deviceId,
            name: name,
            equations: equations,
            isShared: isShared,
            startEndCords: startEndCoords
        )
        await updateDocument(parameters: parameters)
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
