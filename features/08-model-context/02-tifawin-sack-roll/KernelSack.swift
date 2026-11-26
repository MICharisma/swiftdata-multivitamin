// Feature: ModelContext
// Slot 02 — Tifawin sack roll
// Teaches:
// - Before a save, the context lists what it will insert, change, and delete.
// - After the save, all three lists are empty.

import SwiftData
import SwiftUI

@Model
final class KernelSack {
    var sackCode: String
    var kilos: Double
    var crackerName: String

    init(sackCode: String, kilos: Double, crackerName: String) {
        self.sackCode = sackCode
        self.kilos = kilos
        self.crackerName = crackerName
    }
}

struct PendingRoll: Equatable {
    var inserted: [String]
    var changed: [String]
    var deleted: [String]

    init(_ context: ModelContext) {
        func codes(_ models: [any PersistentModel]) -> [String] {
            models.compactMap { ($0 as? KernelSack)?.sackCode }.sorted()
        }
        inserted = codes(context.insertedModelsArray)
        changed = codes(context.changedModelsArray)
        deleted = codes(context.deletedModelsArray)
    }

    var isEmpty: Bool { [inserted, changed, deleted].allSatisfy(\.isEmpty) }
}

enum TifawinRoll {
    /// Yesterday's two sacks, already on the roll.
    static func fileYesterday(in context: ModelContext) throws -> (kept: KernelSack, torn: KernelSack) {
        let kept = KernelSack(sackCode: "TF-0412", kilos: 9.5, crackerName: "Fadma Aït Brahim")
        let torn = KernelSack(sackCode: "TF-0413", kilos: 4, crackerName: "Itto Oubaha")
        context.insert(kept)
        context.insert(torn)
        try context.save()
        return (kept, torn)
    }

    static func morningChanges(kept: KernelSack, torn: KernelSack, in context: ModelContext) {
        kept.kilos = 9.2
        context.delete(torn)
        context.insert(KernelSack(sackCode: "TF-0414", kilos: 11, crackerName: "Fadma Aït Brahim"))
        context.insert(KernelSack(sackCode: "TF-0415", kilos: 7.5, crackerName: "Rkia Aït Lahcen"))
    }
}

struct KernelSackScreen: View {
    var body: some View {
        SackRollDesk().inMemoryStore(for: KernelSack.self)
    }
}

private struct SackRollDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var roll: PendingRoll?
    @State private var stage = 0

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 02",
            title: "Tifawin sack roll",
            situation: "On 6 October 2026 the cooperative reweighs sack TF-0412 at 9.2 kilos, finds TF-0413 split and empties it into the next sack, and fills two new sacks before the roaster comes.",
            teaches: [
                "Before a save, the context lists what it will insert, change, and delete.",
                "After the save, all three lists are empty."
            ]
        ) {
            if let roll {
                Section("Pending in the context") {
                    Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 6) {
                        GridRow { Text("Inserted").bold(); Text(roll.inserted.joined(separator: ", ")) }
                        GridRow { Text("Changed").bold(); Text(roll.changed.joined(separator: ", ")) }
                        GridRow { Text("Deleted").bold(); Text(roll.deleted.joined(separator: ", ")) }
                    }
                    .monospaced()
                }
            }
            Section {
                switch stage {
                case 0:
                    Button("Make the morning's changes") {
                        guard let yesterday = try? TifawinRoll.fileYesterday(in: modelContext) else { return }
                        TifawinRoll.morningChanges(kept: yesterday.kept, torn: yesterday.torn, in: modelContext)
                        roll = PendingRoll(modelContext)
                        stage = 1
                    }
                case 1:
                    Button("Save the roll") {
                        try? modelContext.save()
                        roll = PendingRoll(modelContext)
                        stage = 2
                    }
                default:
                    Text("The roll is saved. Nothing is pending.").foregroundStyle(.secondary)
                }
            }
        }
    }
}
