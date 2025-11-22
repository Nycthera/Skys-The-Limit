import SwiftUI

struct SaveConstellationModalSheetView: View {
    @Binding var name: String
    var onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss
     
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name Your Constellation")
                            .font(.custom("SpaceMono-Bold", size: 24))) { // bigger header
                    TextField("e.g. Orion II", text: $name)
                        .font(.custom("SpaceMono-Regular", size: 20)) // bigger input text
                        .padding(.vertical, 5)
                }
            }
            .navigationTitle(Text("Save Constellation")
                                .font(.custom("SpaceMono-Bold", size: 28))) // bigger nav title
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            onSubmit()
                            dismiss()
                        }
                    }
                    .font(.custom("SpaceMono-Bold", size: 20)) // bigger button
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("SpaceMono-Regular", size: 20)) // bigger button
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
