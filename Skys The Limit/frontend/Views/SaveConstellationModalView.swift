import Foundation
import SwiftUI

struct SaveConstellationModalView: View {
    @Binding var isPresented: Bool
    @Binding var equations: [String]
    @Binding var constellationName: String   // ← FIXED: true binding from parent
    var docID: String? = nil
    var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"

    @State private var isShared: Bool = false

    var onSave: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Save Constellation")
                    .font(.custom("SpaceMono-Bold", size: 38))
                    .padding(.top, 25)

                TextField("Enter constellation name", text: $constellationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.custom("SpaceMono-Regular", size: 38))

                Toggle(isOn: $isShared) {
                    Text("Share with others")
                        .font(.custom("SpaceMono-Regular", size: 32))
                }
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                        onCancel?()
                    }
                    .font(.custom("SpaceMono-Regular", size: 28))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(14)

                    Button("Save") {
                        guard !constellationName.isEmpty else { return }
                        Task {
                            await saveConstellation()
                            onSave?()
                            isPresented = false
                        }
                    }
                    .font(.custom("SpaceMono-Bold", size: 28))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
            .navigationBarHidden(true)
        }
    }

    private func saveConstellation() async {
        guard !constellationName.isEmpty else { return }

        let rowId = docID ?? deviceID

        await update_document(
            rowId: rowId,
            equations: equations,
            name: constellationName
        )

        print("Updated constellation '\(constellationName)' with \(equations.count) equations")
    }
}
