import Foundation
import SwiftUI

struct SaveConstellationModalView: View {
    @Binding var isPresented: Bool
    @Binding var equations: [String]
    @Binding var constellationName: String
    @Binding var startEndCords: [String]
    var docID: String?
    var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
    
    //    @State private var isShared: Bool = false
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Constellation name", text: $constellationName)
                }
            }
            .navigationTitle("Save Constellation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        guard !constellationName.isEmpty else { return }
                        onSave?()
                        isPresented = false
                    }
                    .disabled(constellationName.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        isPresented = false
                        onCancel?()
                    }
                }
            }
        }
    }
}
