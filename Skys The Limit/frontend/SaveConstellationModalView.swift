//
//  SaveConstellationModalView.swift
//  Skys The Limit
//
//  Created by Chris  on 21/11/25.
//

import Foundation
import SwiftUI

struct SaveConstellationModalView: View {
    @Binding var isPresented: Bool
    @Binding var equations: [String]

    // Optional closure called when the user saves
    var onSave: (() -> Void)? = nil

    @State private var constellationName: String = ""
    @State private var isShared: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Save Constellation")
                    .font(.custom("SpaceMono-Bold", size: 24))
                    .padding(.top, 20)

                TextField("Enter constellation name", text: $constellationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.custom("SpaceMono-Regular", size: 18))

                Toggle(isOn: $isShared) {
                    Text("Share with others")
                        .font(.custom("SpaceMono-Regular", size: 18))
                }
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 15) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.custom("SpaceMono-Regular", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("Save") {
                        guard !constellationName.isEmpty else { return }
                        // Here you can call your async function to save the constellation
                        Task {
                            await saveConstellation()
                            onSave?()  // Call the update function
                            isPresented = false
                        }
                    }
                    .font(.custom("SpaceMono-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }

    // Example async save function
    private func saveConstellation() async {
        // Replace this with your actual save logic
        // e.g., await save_to_database(name: constellationName, equations: equations, shared: isShared)
        print("Saving constellation '\(constellationName)' with \(equations.count) equations. Shared: \(isShared)")
    }
}
