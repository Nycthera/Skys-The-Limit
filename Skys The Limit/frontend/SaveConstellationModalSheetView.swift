//
//  SaveConstellationModalSheetView.swift
//  Skys The Limit
//
//  Created by Chris  on 21/11/25.
//

import Foundation
import SwiftUI

struct SaveConstellationModalSheetView: View {
    @Binding var name: String
    var onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name Your Constellation") {
                    TextField("e.g. Orion II", text: $name)
                }
            }
            .navigationTitle("Save Constellation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            onSubmit()
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
