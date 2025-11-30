import SwiftUI
import SwiftData
import SwiftMath
import TipKit

struct ConstellationView: View {
    let deleteConstellationTip = DeleteConstellationTip()
    
    @Environment(\.modelContext) private var context
    
    // 🔹 Use @Query for auto-updating list
    @Query(sort: \ConstellationModel.name) private var allConstellations: [ConstellationModel]
    
    @State private var showModal = false
    @State private var constellationName = ""
    @State private var numberOfStars: Int?
    @State private var isShared = false
    
    @State private var selectedConstellation: ConstellationModel?
    @State private var showDeleteAlert = false
    @State private var constellationToDelete: ConstellationModel?
    
    private var deviceId: String { UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device" }
    
    private static let gridColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16)
    ]
    
    // Filtered list for the current user
    private var constellationsList: [ConstellationModel] {
        allConstellations.filter { $0.userId == deviceId }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("Space")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                TipView(deleteConstellationTip)
                    .tipBackground(.white.opacity(0.7))
                ScrollView {
                    LazyVGrid(columns: Self.gridColumns, spacing: 20) {
                        ForEach(constellationsList) { constellation in
                            ConstellationCellView(constellation: constellation)
                                .onTapGesture {
                                    selectedConstellation = constellation
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    constellationToDelete = constellation
                                    showDeleteAlert = true
                                }
                        }
                    }
                    .padding()
                }
            }
            
            Button {
                showModal = true
            } label: {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.6))
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
                    isShared: $isShared
                )
            }
        }
        .fullScreenCover(item: $selectedConstellation) { constellation in
            MyConstellationMainView(ID: constellation.id)
        }
        .alert("Delete Constellation?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let c = constellationToDelete {
                    let service = ConstellationDataService(context: context)
                    service.deleteConstellation(c)
                }
                deleteConstellationTip.invalidate(reason: .actionPerformed)
            }
            Button("Cancel", role: .cancel) {
                deleteConstellationTip.invalidate(reason: .actionPerformed)
            }
        } message: {
            Text("Are you sure you want to delete “\(constellationToDelete?.name ?? "")”?")
        }
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
    ConstellationView()
        .modelContainer(for: ConstellationModel.self)
}
