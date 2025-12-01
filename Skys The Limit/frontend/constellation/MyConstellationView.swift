import SwiftUI
import SwiftData
import SwiftMath
import TipKit

struct MyConstellationView: View {
    let deleteConstellationTip = DeleteConstellationTip()
    
    @Environment(\.modelContext) private var context
    
    // 🔹 Use @Query for auto-updating list
    @Query(sort: \ConstellationModel.name) private var allConstellations: [ConstellationModel]
    
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int?
    
    @State private var selectedConstellation: ConstellationModel?
    @Namespace var namespace
    private var deviceId: String { UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device" }
    
    private static let gridColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16)
    ]
    
    // For pulsing glow animation
    @State private var showGlow = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Image("Space")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    TipView(deleteConstellationTip)
                        .tipBackground(.white.opacity(0.7))
                    
                    if allConstellations.isEmpty {
                        // ========================
                        // Content Unavailable View
                        // ========================
                        VStack(spacing: 20) {
                            // Pulsating sparkle icon
                            Image(systemName: "sparkles")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.7), Color.yellow.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.white.opacity(0.5), radius: 20, x: 0, y: 0)
                                .scaleEffect(showGlow ? 1.1 : 0.95)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: showGlow)
                            
                            Text("No Constellations Yet")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Tap the + button below to create your first constellation and start connecting the stars!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.black.opacity(0.8), Color.black.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .edgesIgnoringSafeArea(.all)
                        )
                        .onAppear {
                            showGlow = true
                        }
                        
                    } else {
                        // ========================
                        // Existing Grid of Constellations
                        // ========================
                        ScrollView {
                            LazyVGrid(columns: Self.gridColumns, spacing: 20) {
                                ForEach(allConstellations) { constellation in
                                    ConstellationCellView(constellation: constellation)
                                        .onTapGesture {
                                            selectedConstellation = constellation
                                        }
                                        .contextMenu {
                                            Button("Delete Constellation", systemImage: "trash", role: .destructive) {
                                                context.delete(constellation)
                                                try? context.save()
                                            }
                                        }
                                        .matchedTransitionSource(id: constellation.id, in: namespace)
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                // ========================
                // Add Constellation Button
                // ========================
                Button {
                    showModal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                .padding(20)
                .sheet(isPresented: $showModal) {
                    ConstellationModalView(
                        name: $constellationName,
                        numberOfStars: Binding(
                            get: { numberOfStars.map(String.init) ?? "" },
                            set: { newValue in
                                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                                numberOfStars = Int(trimmed)
                            }
                        ),
                    ) {
                        openLatestConstellation()
                    }
                }
            }
            .navigationDestination(item: $selectedConstellation) { constellation in
                SavedConstellationMainView(consetallionModal: constellation)
                    .navigationTransition(.zoom(sourceID: constellation.id, in: namespace))
            }
        }
    }
    
    func openLatestConstellation() {
        let latest = allConstellations.last
        selectedConstellation = latest
    }
}

// ==========================================================
// MARK: - Constellation Cell
// ==========================================================
private struct ConstellationCellView: View {
    let constellation: ConstellationModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text(constellation.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("\(constellation.equations.count) equations")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    MyConstellationView()
        .modelContainer(for: ConstellationModel.self)
}
