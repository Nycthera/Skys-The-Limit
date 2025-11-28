import Foundation
import SwiftData
import JSONCodable

// MARK: - SwiftData Model
@Model
class ConstellationModel {
    @Attribute(.unique) var id: String
    var userId: String
    var name: String
    var equations: [String]
    var isShared: Bool
    var startEndCords: [String]

    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        equations: [String],
        isShared: Bool,
        startEndCords: [String]
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.equations = equations
        self.isShared = isShared
        self.startEndCords = startEndCords
    }
}


// MARK: - SwiftData CRUD Service
@MainActor
class ConstellationDataService {

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - CREATE
    func createConstellation(
        userId: String,
        name: String,
        equations: [String],
        isShared: Bool,
        startEndCords: [String]
    ) {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled"
            : name

        let newConstellation = ConstellationModel(
            userId: userId,
            name: finalName,
            equations: equations,
            isShared: isShared,
            startEndCords: startEndCords
        )

        context.insert(newConstellation)

        do {
            try context.save()
            print("Saved constellation: \(newConstellation.name)")
        } catch {
            print("❌ Save error: \(error)")
        }
    }

    // MARK: - READ (FETCH ALL BY USER)
    func fetchConstellations(userId: String) -> [ConstellationModel] {
        let descriptor = FetchDescriptor<ConstellationModel>(
            predicate: #Predicate { $0.userId == userId }
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Fetch error: \(error)")
            return []
        }
    }

    // MARK: - UPDATE
    func updateConstellation(
        constellation: ConstellationModel,
        newName: String? = nil,
        newEquations: [String]? = nil,
        newIsShared: Bool? = nil,
        newStartEndCords: [String]? = nil
    ) {
        if let newName { constellation.name = newName }
        if let newEquations { constellation.equations = newEquations }
        if let newIsShared { constellation.isShared = newIsShared }
        if let newStartEndCords { constellation.startEndCords = newStartEndCords }

        do {
            try context.save()
            print("Updated constellation: \(constellation.name)")
        } catch {
            print("❌ Update error: \(error)")
        }
    }

    // MARK: - DELETE
    func deleteConstellation(_ constellation: ConstellationModel) {
        context.delete(constellation)

        do {
            try context.save()
            print("Deleted constellation")
        } catch {
            print("❌ Delete error: \(error)")
        }
    }
}
