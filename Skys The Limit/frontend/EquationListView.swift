
import SwiftUI
import SwiftMath  // means swift math not working

struct EquationListView: View {
   
    @State private var equationText = "y = x^{2}"

    var body: some View {
        VStack {
         Spacer()
         
         // The live-rendering display area from the SwiftMath library.
         // If you get an error on this line, it means Xcode's build system
         // cannot find the compiled code from the SwiftMath library.
            MathView()
                .font(.system(size: 40))
                .padding()
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
         
         // A helper view to show the raw LaTeX string (useful for debugging).
         Text("Raw LaTeX: \(equationText)")
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
                .padding(.bottom)
         
         // The custom keyboard component. It passes changes up to this
         
         MathKeyboardView(latexString: $equationText)
         }
            .padding()
         }
    }


struct EquationListView_Previews: PreviewProvider {
    static var previews: some View {
        EquationListView()
    }
}
