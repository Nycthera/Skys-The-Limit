import SwiftUI
import SwiftData
import SwiftMath
import TipKit

struct CustomConstellationView: View {
    let editEquationTip = EditEquationTip()
    
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []
    
    @State private var showSaveModal = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    
    @Binding var editingLatexString: String
    @Binding var editingMathString: String
    @Binding var editingIndex: Int?
    @Bindable var consetallionModal: ConstellationModel
    
    @Environment(\.dismiss) var dismiss
    
    
    private let sidebarWidth: CGFloat = 250
    
    var body: some View {
        
        
        //game area
        VStack(spacing: 10) {
            CustomGraphCanvasView(stars: stars, successfulLines: successfulLines, consetallionModal: consetallionModal)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
            
            Spacer()
                  
                MathView(
                    equation: "y=\(editingMathString)",
                    fontSize: 31
                )
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
            
            
            MathKeyboardView(
                latexString: $editingLatexString,
                mathString: $editingMathString
            )
            .fixedSize(horizontal: false, vertical: true)
            
            Button {
                guard !editingMathString.isEmpty else { return }
                
                if let index = editingIndex {
                    consetallionModal.equations[index] = "y=\(editingMathString)"
                } else {
                    consetallionModal.equations.append("y=\(editingMathString)")
                }
                
                editingLatexString = ""
                editingMathString = ""
                editingIndex = nil
                
                Task { await EditEquationTip.editEquationEvent.donate()}
                
            } label: {
                Text(editingIndex != nil ? "Update Equation" : "Add Equation")
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .cornerRadius(15)
            }
            .buttonStyle(.glassProminent)
            .padding(.top, 10)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        
        
        .background(
            Image("Space")
                .resizable()
                .scaledToFill()
                .backgroundExtensionEffect()
            
        )
        
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await EditEquationTip.customConstellationViewVisitedEvent.donate()}
        }
        .onChange(of: consetallionModal.equations) { _ in
            updateStarsFromEquations()
        }
        .navigationViewStyle(.stack)
    }
    // MARK: - Star Update
    private func updateStarsFromEquations() {
        stars = []
        successfulLines = []
        
        for eq in consetallionModal.equations {
            let engine = MathEngine(equation: eq)
            guard let points = engine.evaluate(), !points.isEmpty else { continue }
            
            stars.append(contentsOf: points.map { CGPoint(x: $0.x, y: $0.y) })
            successfulLines.append(points)
        }
    }
}
