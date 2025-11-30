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
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                Text("Equations")
                    .font(.title)
                    .foregroundColor(.white)
                
                TipView(editEquationTip)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(equations.indices, id: \.self) { idx in
                            MathView(
                                equation: equations[idx],
                                textAlignment: .left,
                                fontSize: 31
                            )
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .padding(3)
                            
                            .onTapGesture {
                                editingString = equations[idx]
                                editingIndex = idx
                            }
                            .onLongPressGesture {
                                withAnimation {
                                    equations.remove(at: idx)
                                    if editingIndex == idx {
                                        editingString = ""
                                        editingIndex = nil
                                    } else if let current = editingIndex, current > idx {
                                        editingIndex = current - 1
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                Spacer()
            }
            
            .clipped()
        }
    }
    
}

