import Foundation
import Appwrite
import UIKit
import AppwriteModels

// MARK: - Constants
let databaseID = "69114f5e001d9116992a"
let tableID = "constellation"
let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"

// MARK: - Globals
var userTableIDs: [String] = []

// MARK: - Create (POST)
func post_to_database(equations: [String] = ["y=x^2"], isShared: Bool = false) async {
    do {
        let document = try await appwrite.table.createRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: ID.unique(),
            data: [
                "userid": deviceID,
                "equations": equations,
                "isShared": isShared
            ],
            permissions: [
                Permission.read(Role.user(deviceID)),
                Permission.update(Role.user(deviceID)),
                Permission.delete(Role.user(deviceID))
            ]
        )
        print("Document created: \(document.id)")
    } catch {
        print("Error creating document: \(error.localizedDescription)")
    }
}

// MARK: - Read (LIST)
func list_documents_for_user() async {
    do {
        let rowList = try await appwrite.table.listRows(
            databaseId: databaseID,
            tableId: tableID,
            queries: [
                Query.equal("userid", value: deviceID)
            ]
        )
        userTableIDs = rowList.rows.map { $0.id }
        print("User document IDs: \(userTableIDs)")
    } catch {
        print("Error listing documents: \(error.localizedDescription)")
    }
}

// MARK: - Read (GET single document)
func get_document(rowId: String) async {
    do {
        let document = try await appwrite.table.getRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        print("Document \(rowId): \(document)")
    } catch {
        print("Error fetching document \(rowId): \(error.localizedDescription)")
    }
}

// MARK: - Update (PUT)
func update_document_for_user(equations: [String]) async {
    guard let docIdToUpdate = userTableIDs.first else {
        print("No existing document found. Creating one instead.")
        await post_to_database(equations: equations)
        return
    }
    
    do {
        let updated = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: docIdToUpdate,
            data: [
                "userid": deviceID,
                "equations": equations
            ],
            permissions: [
                Permission.read(Role.any()) // optional: make public readable
            ]
        )
        print("Document updated: \(updated.id)")
    } catch {
        print("Error updating document: \(error.localizedDescription)")
    }
}

// MARK: - Delete (DELETE)
func delete_document(rowId: String) async {
    do {
        try await appwrite.table.deleteRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        print("Document deleted: \(rowId)")
    } catch {
        print("Error deleting document: \(error.localizedDescription)")
    }
}

// MARK: - Share / Unshare
func toggle_share(rowId: String, share: Bool) async {
    do {
        let updated = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId,
            data: [
                "isShared": share
            ]
        )
        print(share ? " Constellation shared: \(updated.id)" : "Constellation unshared: \(updated.id)")
    } catch {
        print("❌ Error toggling share state: \(error.localizedDescription)")
    }
}

// MARK: - Check shared document (public access)
func get_shared_document(rowId: String) async {
    do {
        let document = try await appwrite.table.getRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        print("Shared document fetched: \(document)")
    } catch {
        print("Error fetching shared document: \(error.localizedDescription)")
    }
}
