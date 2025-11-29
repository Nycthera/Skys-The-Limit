import SwiftUI

struct SaveConstellationModalSheetView: View {
    @Binding var name: String
    var onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name Your Constellation")
                    .font(.largeTitle)
                ) { // bigger header
                    TextField("e.g. Orion II", text: $name)
                        .font(.caption) // bigger input text
//                        .padding(.vertical, 5)
                }
            }
            .navigationTitle(Text("Save Constellation"))
                .font(.largeTitle) // bigger nav title
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            onSubmit()
                            dismiss()
                        }
                    }
                    .font(.title)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.title)
                }
            }
        }
    }
}

#Preview {
    SaveConstellationModalSheetView(
        name: .constant(""),
        onSubmit: { }
    )
}
