import SwiftUI
import SwiftData

struct ConstellationModalView: View {
    @Binding var name: String
    @Binding var numberOfStars: String
    @Binding var isShared: Bool

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    // Temporary placeholder
    let tempEquations: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Constellation Info")) {
                    TextField("Constellation Name", text: $name)

                    TextField("Number of Stars", text: $numberOfStars)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Constellation")
            .toolbar {

                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }

                // Done
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                        // Use SwiftData service
                        let service = ConstellationDataService(context: context)

                        // Generate placeholder coords
                        let startEndCords: [String] = []

                        // Save using SwiftData
                        service.createConstellation(
                            userId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device",
                            name: name,
                            equations: tempEquations,
                            isShared: isShared,
                            startEndCords: startEndCords
                        )

                        dismiss()
                    }
                }
            }
        }
    }
}
