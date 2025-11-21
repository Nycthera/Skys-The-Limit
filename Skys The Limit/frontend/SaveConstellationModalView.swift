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
      var existingName: String   // <-- ADD THIS

      @State private var constellationName: String = ""
      @State private var isShared: Bool = false
  
    init(isPresented: Binding<Bool>, equations: Binding<[String]>, existingName: String, onSave: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self._equations = equations
        self.existingName = existingName
        self._constellationName = State(initialValue: existingName)
        self.onSave = onSave
    }

    var onSave: (() -> Void)? = nil

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
        guard !constellationName.isEmpty else { return }
        
        await post_to_database(
            equations: equations,
            name: constellationName
        )
        
        print("Saved constellation '\(constellationName)' with \(equations.count) equations")
    }
}
