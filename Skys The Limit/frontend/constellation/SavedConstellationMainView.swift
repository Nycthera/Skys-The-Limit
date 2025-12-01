//
//  SavedConstellationMainView.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.

import SwiftUI

struct SavedConstellationMainView: View {
    // MARK: - State
    @State private var successfulLines: [[(x: Double, y: Double)]] = []

    @State private var editingLatexString: String = ""
    @State private var editingMathString: String = ""
    @State private var editingIndex: Int?

    @State private var showSaveModal = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) var dismiss
    
    @Bindable var consetallionModal: ConstellationModel



    private let sidebarWidth: CGFloat = 250
    
    var body: some View {
        GeometryReader { geometry in
            NavigationSplitView {
                CustomSidebarView(
                    equations: $consetallionModal.equations,
                    editingString: $editingLatexString,
                    editingIndex: $editingIndex,
                    ID: $consetallionModal.id
                )
                
            } detail: {
                CustomConstellationView(
                    editingLatexString: $editingLatexString,
                    editingMathString: $editingMathString,
                    editingIndex: $editingIndex,
                    consetallionModal: consetallionModal
                )
                .navigationTitle($consetallionModal.name)
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
