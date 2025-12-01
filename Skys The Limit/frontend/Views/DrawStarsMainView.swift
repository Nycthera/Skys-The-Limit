//
//  DrawStarsMainView.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.
//

import SwiftUI
import SwiftMath
import TipKit
import SwiftData

struct DrawStarsMainView: View {
    @StateObject private var viewModel = EquationPuzzleViewModel()
    @EnvironmentObject var equationStore: EquationStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context    // ← SwiftData context
    
    @State private var currentMathString: String = ""
    @State private var isSidebarCollapsed: Bool = false
    
    // confetti stuff
    @State private var isCelebrating = false
    
    // saving constellation
    @State private var showSaveModal = false
    @State private var newConstellationName = ""
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                NavigationSplitView {
                    SidebarView(width: geometry.size.width * 0.20, stars: viewModel.stars, successfulEquations: viewModel.successfulEquations)
                    //the error is here cannot find geometry in scope
                } detail: {
                    EquationListView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            // PUZZLE COMPLETE OVERLAY
            if viewModel.isPuzzleComplete {
                ZStack {
                    ConfettiView(isAnimating: $isCelebrating)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                        .zIndex(10)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        Text("You Win!")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                            .shadow(radius: 5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isCelebrating = false
                        showSaveModal = true
                    }
                    .zIndex(20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .onAppear {
                    DispatchQueue.main.async {
                        isCelebrating = true
                    }
                }
            }
        }
        .sheet(isPresented: $showSaveModal) {
            
            SaveConstellationModalView(
                isPresented: $showSaveModal,
                equations: $viewModel.successfulEquations,
                constellationName: $newConstellationName,
                startEndCords: Binding(get: {
                    let stars = viewModel.stars
                    guard let first = stars.first, let last = stars.last else { return [] }
                    return [
                        "\(Int(first.x)),\(Int(first.y))",
                        "\(Int(last.x)),\(Int(last.y))"
                    ]
                }, set: { _ in }),
                docID: nil,
                
                onSave: {
                    saveCompletedConstellation()
                    dismiss()
                },
                
                onCancel: {
                    dismiss()
                }
            )
        }
    }
    // ==========================================================
    //                SAVE TO SWIFTDATA
    // ==========================================================
    func saveCompletedConstellation() {
        let equationStrings = viewModel.successfulEquations
        
        // Auto compute start and end coordinates
        let stars = viewModel.stars
        let startEndCoords: [String] = {
            guard let first = stars.first, let last = stars.last else { return [] }
            return [
                "\(Int(first.x)),\(Int(first.y))",
                "\(Int(last.x)),\(Int(last.y))"
            ]
        }()
        
        // SwiftData service
        context.insert(ConstellationModel(name: newConstellationName, equations: equationStrings, startEndCords: startEndCoords))
        
        print("Saved constellation '\(newConstellationName)' with \(equationStrings.count) equations.")
    }
}

private struct SidebarView: View {
    let width: CGFloat
    let stars: [CGPoint]
    let successfulEquations: [String]

    var body: some View {
        VStack(spacing: 12) {
            List {
                ForEach(successfulEquations, id: \.self) { eq in
                    MathView(
                        equation: "y=\(eq)",
                        textAlignment: .left,
                        fontSize: 31
                    )
                    .foregroundStyle(.white)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, 20)   // <-- Now it will show
        }
        .navigationTitle("Equations")
        .frame(width: width)            // <-- IMPORTANT: Your width is applied here
    }
}

