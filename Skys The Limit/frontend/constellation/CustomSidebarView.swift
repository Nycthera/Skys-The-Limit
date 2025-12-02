//
//  CustomSidebarView.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.
//

import SwiftUI
import SwiftMath
import SwiftData
import TipKit

// MARK: - Sidebar
struct CustomSidebarView: View {
    @Binding var equations: [String]
    @Binding var editingString: String
    @Binding var editingIndex: Int?
    
    let ID: String
    let editEquationTip = EditEquationTip()
    
    var body: some View {
        VStack(spacing: 12) {
            TipView(editEquationTip)
            
            List {
                ForEach(equations.indices, id: \.self) { idx in
                    Button {
                        editingString = equations[idx]
                        editingIndex = idx
                    } label: {
                        MathView(
                            equation: "\(equations[idx])",
                            textAlignment: .left,
                            fontSize: 31
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(editingIndex == idx ? Color.blue : Color.clear)
                }
                .onDelete { indexSet in
                    equations.remove(atOffsets: indexSet)
                }
            }
            
        }
        .navigationTitle("Equations")
    }
    
}
