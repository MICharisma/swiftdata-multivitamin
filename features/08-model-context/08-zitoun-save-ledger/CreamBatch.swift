// Feature: ModelContext
// Slot 08 — Zitoun save ledger
// Teaches:
// - Each save posts ModelContext.didSave with the identifiers it inserted, updated, and deleted.
// - The notification's userInfo carries PersistentIdentifier arrays, not the models.

import Foundation
import SwiftData
import SwiftUI

@Model
final class CreamBatch {
    var batchCode: String
    var product: String
    var arganMillilitres: Int

    init(batchCode: String, product: String, arganMillilitres: Int) {
        self.batchCode = batchCode
        self.product = product
        self.arganMillilitres = arganMillilitres
    }
}

struct SaveReceipt: Equatable, Sendable {
    let inserted: [PersistentIdentifier]
    let updated: [PersistentIdentifier]
    let deleted: [PersistentIdentifier]

    init(_ notification: Notification) {
        func identifiers(_ key: ModelContext.NotificationKey) -> [PersistentIdentifier] {
            notification.userInfo?[key.rawValue] as? [PersistentIdentifier] ?? []
        }
        inserted = identifiers(.insertedIdentifiers)
        updated = identifiers(.updatedIdentifiers)
        deleted = identifiers(.deletedIdentifiers)
    }

    var line: String {
        "inserted \(inserted.count) · updated \(updated.count) · deleted \(deleted.count)"
    }
}

enum ZitounAtelier {
    static func morning(in context: ModelContext) throws {
        let nightCream = CreamBatch(batchCode: "ZT-311", product: "Argan night cream", arganMillilitres: 400)
        let soap = CreamBatch(batchCode: "ZT-312", product: "Black soap with argan", arganMillilitres: 150)
        context.insert(nightCream)
        context.insert(soap)
        try context.save()

        nightCream.arganMillilitres = 450
        try context.save()

        context.delete(soap)
        try context.save()
    }
}

struct CreamBatchScreen: View {
    var body: some View {
        SaveLedgerDesk().inMemoryStore(for: CreamBatch.self)
    }
}

private struct SaveLedgerDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var receipts: [SaveReceipt] = []

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 08",
            title: "Zitoun save ledger",
            situation: "On 13 October 2026 Salma Idrissi of Atelier Zitoun in Marrakech mixes a night cream and a black soap from the Amazir bottle. She adds 50 ml more oil to the cream, then pulls the soap when its lye tests high.",
            teaches: [
                "Each save posts ModelContext.didSave with the identifiers it inserted, updated, and deleted.",
                "The notification's userInfo carries PersistentIdentifier arrays, not the models."
            ]
        ) {
            Section("didSave receipts") {
                ForEach(Array(receipts.enumerated()), id: \.offset) { index, receipt in
                    LabeledContent("Save \(index + 1)", value: receipt.line)
                }
                Button("Work the morning batches") { try? ZitounAtelier.morning(in: modelContext) }
                    .disabled(!receipts.isEmpty)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { notification in
            guard (notification.object as? ModelContext) === modelContext else { return }
            receipts.append(SaveReceipt(notification))
        }
    }
}
