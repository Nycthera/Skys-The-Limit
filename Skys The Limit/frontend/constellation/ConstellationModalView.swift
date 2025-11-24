import SwiftUI

struct ConstellationModalView: View {
    @Binding var name: String
    @Binding var numberOfStars: String
    @Binding var isShared: Bool
    @Environment(\.dismiss) var dismiss
    
    // Placeholder equations (or could be empty)
    let tempEquations: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Constellation Info")) {
                    TextField("Constellation Name", text: $name)
                    TextField("Number of Stars", text: $numberOfStars)
                        .keyboardType(.numberPad)
                    Toggle("Shared with others?", isOn: $isShared)
                }
            }
            .navigationTitle("New Constellation")
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
                
                // Done button
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        // Action
                        guard !name.isEmpty else { return }
                        Task {
                            // 1. Check if user has any documents
                            let _ = await checkIfUserHasDocument()
                            
                            // 2. Generate a placeholder start/end coordinates (empty for now)
                            let startEndCords: [String] = []
                            
                            // 3. Create parameters struct
                            let parameters = AppwriteFunctionsParameters(
                                id: nil,
                                userId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device",
                                name: name,
                                equations: tempEquations,
                                isShared: isShared,
                                startEndCords: startEndCords
                            )
                            
                            // 4. Save to database
                            await postToDatabase(parameters: parameters)
                            
                            // 5. Dismiss modal
                            dismiss()
                        }
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
