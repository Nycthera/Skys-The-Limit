import Foundation
import SwiftData
//import JSONCodable

// MARK: - SwiftData Model
@Model
class ConstellationModel {
    @Attribute(.unique) var id: String

    var name: String
    var equations: [String]
    var startEndCords: [String]

    init(
        id: String = UUID().uuidString,
        name: String,
        equations: [String],
        startEndCords: [String]
    ) {
        self.id = id
        self.name = name
        self.equations = equations
        self.startEndCords = startEndCords
    }
}

// Todo

// fix the draw the stars view -> js copy from the other one
// using content unavavlibe view for the empty states, nothing to show (all equations are gone in saved con view)
// making stuff more consitennt
