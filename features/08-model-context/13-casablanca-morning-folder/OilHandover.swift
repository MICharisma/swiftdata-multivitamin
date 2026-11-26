// Feature: ModelContext
// Slot 13 — Casablanca morning folder
// Teaches:
// - One @ModelActor save deletes the scorched pan and files the cracking tally with the press run.
// - A fresh context reads only what that save left in the store.

import SwiftData
import SwiftUI

enum ArganFolder {
    static let types: [any PersistentModel.Type] = [
        CrackingTally.self,
        PanBatch.self,
        PressRun.self,
        OilHandover.self
    ]

    static func hang(in context: ModelContext) throws -> [PersistentIdentifier] {
        let crack = CrackingTally(
            crackerName: "Fadma Aït Brahim",
            kernelKilos: 9.5,
            crackedOn: GregorianDay.date(year: 2026, month: 10, day: 5, timeZoneIdentifier: "Africa/Casablanca")
        )
        let scorched = PanBatch(batchCode: "TF-0416-R", kernelKilos: 6, outcome: "Scorched")
        let press = PressRun(runCode: "AM-1009", pressOperator: "Youssef Bennani", roastedKilos: 22, oilLitres: 10)
        context.insert(crack)
        context.insert(scorched)
        context.insert(press)
        try context.save()
        return [crack.persistentModelID, scorched.persistentModelID, press.persistentModelID]
    }
}

struct FolderManifest: Codable, Equatable, Sendable {
    var crackerName: String
    var kernelKilos: Double
    var pressRun: String
    var oilLitres: Double
    var scorchedBatches: Int
}

@Model
final class OilHandover {
    var manifest: FolderManifest

    init(manifest: FolderManifest) {
        self.manifest = manifest
    }
}

struct ArganFolderAudit: Sendable {
    let manifest: FolderManifest
    let filedHandover: Bool
}

@ModelActor
actor FolderClerk {
    func closeMorning(_ sourceIDs: [PersistentIdentifier]) throws -> ArganFolderAudit {
        guard sourceIDs.count == 3 else { throw CocoaError(.fileReadCorruptFile) }

        let crack = modelContext.model(for: sourceIDs[0]) as! CrackingTally
        let scorched = modelContext.model(for: sourceIDs[1]) as! PanBatch
        let press = modelContext.model(for: sourceIDs[2]) as! PressRun

        // The scorched pan was a mistake; tear that card up before the folder closes.
        modelContext.delete(scorched)
        let manifest = FolderManifest(
            crackerName: crack.crackerName,
            kernelKilos: crack.kernelKilos,
            pressRun: press.runCode,
            oilLitres: press.oilLitres,
            scorchedBatches: 0
        )
        modelContext.insert(OilHandover(manifest: manifest))
        try modelContext.save()

        let filed = try modelContext.fetch(FetchDescriptor<OilHandover>()).first
        let scorchedLeft = try modelContext.fetchCount(FetchDescriptor<PanBatch>())
        var closed = filed?.manifest ?? manifest
        closed.scorchedBatches = scorchedLeft
        return ArganFolderAudit(manifest: closed, filedHandover: filed != nil)
    }
}

struct OilHandoverScreen: View {
    var body: some View {
        OilHandoverDesk().inMemoryStore(for: ArganFolder.types)
    }
}

private struct OilHandoverDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var sourceIDs: [PersistentIdentifier] = []
    @State private var audit: ArganFolderAudit?
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 13",
            title: "Casablanca morning folder",
            situation: "On 20 October 2026 Leila Amrani of Maison d'Argane in Casablanca closes the Tamanar-to-Essaouira folder before the tasting for Hôtel Hyatt. Fadma's kernels and Youssef's press stay. The scorched pan does not.",
            teaches: [
                "One @ModelActor save deletes the scorched pan and files the cracking tally with the press run.",
                "A fresh context reads only what that save left in the store."
            ]
        ) {
            if let audit {
                Section("Maison d'Argane") {
                    LabeledContent("Cracker", value: "\(audit.manifest.crackerName) · \(audit.manifest.kernelKilos.formatted()) kg")
                    LabeledContent("Press", value: "\(audit.manifest.pressRun) · \(audit.manifest.oilLitres.formatted()) L")
                    LabeledContent("Scorched pans left", value: "\(audit.manifest.scorchedBatches)")
                    Text(audit.filedHandover ? "The handover card is filed." : "No handover card.")
                        .foregroundStyle(.secondary)
                }
            } else if sourceIDs.isEmpty {
                Button("Hang the three cards") {
                    do { sourceIDs = try ArganFolder.hang(in: modelContext) }
                    catch { failure = error.localizedDescription }
                }
            } else {
                ProgressView("Closing the morning folder")
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
        .task(id: sourceIDs) {
            guard !sourceIDs.isEmpty, audit == nil else { return }
            let clerk = FolderClerk(modelContainer: modelContext.container)
            do { audit = try await clerk.closeMorning(sourceIDs) }
            catch { failure = error.localizedDescription }
        }
    }
}
