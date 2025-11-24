import Foundation
import Appwrite
import UIKit
import AppwriteModels
import JSONCodable

// MARK: - Struct for Appwrite Parameters
struct AppwriteFunctionsParameters: Codable, Identifiable {
    let id: String?               // $id
    let userId: String            // consistent naming
    var name: String
    var equations: [String]
    var isShared: Bool
    var startEndCords: [String]   // match Appwrite column exactly

    init(
        id: String? = nil,
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

// --- Global Constants & Variables ---
let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
let databaseId = "69114f5e001d9116992a"
let tableId = "constellation"
var userTableIds: [String] = []

// MARK: - Create a new document
func postToDatabase(parameters: AppwriteFunctionsParameters) async {
    let finalName = parameters.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : parameters.name

    do {
        let document = try await appwrite.table.createRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: ID.unique(),
            data: [
                "userid": parameters.userId,                   // matches Appwrite column
                "name": finalName,
                "equations": parameters.equations,
                "isShared": parameters.isShared,
                "startEndCords": parameters.startEndCords    // matches Appwrite column
            ],
            permissions: [
                Permission.read(Role.any()),
                Permission.update(Role.any()),
                Permission.delete(Role.any())
            ]
        )
        print("Document created successfully: \(document.id)")
        userTableIds.append(document.id)
    } catch {
        print("Error creating document: \(error.localizedDescription)")
    }
}

// MARK: - List documents for user
func listDocumentsForUser() async {
    do {
        let rowList = try await appwrite.table.listRows(
            databaseId: databaseId,
            tableId: tableId,
            queries: [
                Query.equal("userid", value: deviceId)   // matches Appwrite column
            ]
        )
        userTableIds = rowList.rows.map { $0.id }
        print(userTableIds.isEmpty ? "No documents found for this user." : "Fetched row IDs: \(userTableIds)")
    } catch {
        print("Error listing documents: \(error.localizedDescription)")
    }
}

// MARK: - Update document
func updateDocument(parameters: AppwriteFunctionsParameters) async {
    guard let rowId = parameters.id else {
        print("Error: No document ID provided for update.")
        return
    }

    let finalName = parameters.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : parameters.name

    do {
        _ = try await appwrite.table.updateRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: rowId,
            data: [
                "name": finalName,
                "equations": parameters.equations,
                "isShared": parameters.isShared,
                "startEndCords": parameters.startEndCords
            ],
            permissions: [Permission.read(Role.any())]
        )
        print("Document updated successfully.")
    } catch {
        print("Error updating document: \(error.localizedDescription)")
    }
}

// MARK: - Delete document
func deleteDocument(rowId: String) async {
    do {
        try await appwrite.table.deleteRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: rowId
        )
        print("Document deleted: \(rowId)")
    } catch {
        print("Error deleting document: \(error.localizedDescription)")
    }
}

// MARK: - Toggle share
func toggleShare(rowId: String, share: Bool) async {
    do {
        let updated = try await appwrite.table.updateRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: rowId,
            data: ["isShared": share]
        )
        print(share ? "Constellation shared: \(updated.id)" : "Constellation unshared: \(updated.id)")
    } catch {
        print("Error toggling share state: \(error.localizedDescription)")
    }
}

// MARK: - Fetch single document as AppwriteFunctionsParameters
func getDocumentForUser(rowId: String) async -> AppwriteFunctionsParameters? {
    do {
        let document = try await appwrite.table.getRow(
            databaseId: databaseId,
            tableId: tableId,
            rowId: rowId
        )

        let name = ((document.data["name"] as? AnyCodable)?.value as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let equations = (document.data["equations"] as? AnyCodable)?.value as? [String] ?? []
        let isShared = (document.data["isShared"] as? AnyCodable)?.value as? Bool ?? false
        let startEndCords = (document.data["startEndCords"] as? AnyCodable)?.value as? [String] ?? []
        let userId = (document.data["userid"] as? AnyCodable)?.value as? String ?? "unknown"

        return AppwriteFunctionsParameters(
            id: document.id,
            userId: userId,
            name: name.isEmpty ? "Untitled" : name,
            equations: equations,
            isShared: isShared,
            startEndCords: startEndCords
        )
    } catch {
        print("Error fetching document: \(error.localizedDescription)")
        return nil
    }
}

// MARK: - Check if user has any document
func checkIfUserHasDocument() async -> Bool {
    await listDocumentsForUser()
    print("Response from checkIfUserHasDocument(): \(userTableIds)")
    return userTableIds.isEmpty
}
