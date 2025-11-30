//
//  SavedConstellationMainView.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.

import SwiftUI

struct SavedConstellationMainView: View {
    // MARK: - State
    @State private var arrayOfEquations: [String] = []
    @State private var stars: [CGPoint] = []
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int?

    @State private var showSaveModal = false

    @State private var constellationName: String = ""
    @State private var startEndCoords: [String] = [""]

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) var dismiss


    let ID: String
    private let sidebarWidth: CGFloat = 250
    
    var body: some View {
        GeometryReader { geometry in
            NavigationSplitView {
                CustomSidebarView(
                    equations: $arrayOfEquations,
                    editingString: $editingLatexString,
                    editingIndex: $editingIndex,
                    ID: ID
                )
                
                //the error is here cannot find geometry in scope
            } detail: {
                CustomConstellationView(
                    ID: ID,
                    arrayOfEquations: $arrayOfEquations,        // <-- pass binding
                    editingLatexString: $editingLatexString,
                    editingMathString: $editingMathString,
                    editingIndex: $editingIndex
                )
                .sheet(isPresented: $showSaveModal) {
                    SaveConstellationModalView(
                        isPresented: $showSaveModal,
                        equations: $arrayOfEquations,
                        constellationName: $constellationName,
                        startEndCords: $startEndCoords,
                        docID: ID,
                        onSave: {
                            saveConstellation()
                            showSaveModal = false
                            dismiss()
                        }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()      // works on iPad too
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.body)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showSaveModal = true } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
                }
                
            }
        }
    }
    
    private func saveConstellation() {
        let service = ConstellationDataService(context: context)
        let equationsWithY = arrayOfEquations.map { $0.starts(with: "y =") ? $0 : "y = \($0)" }

        if let constellation = service.fetchConstellations(userId: UIDevice.current.identifierForVendor!.uuidString)
            .first(where: { $0.id == ID }) {
            service.updateConstellation(
                constellation: constellation,
                newName: constellationName,
                newEquations: equationsWithY,
                newStartEndCords: startEndCoords
            )
        }
    }
}
