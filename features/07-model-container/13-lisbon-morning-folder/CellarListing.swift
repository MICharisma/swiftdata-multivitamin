// Feature: ModelContainer and ModelConfiguration
// Slot 13 — Lisbon morning folder
// Teaches:
// - One container can join a store file and an in-memory store, each for its own models.
// - Reopening the file brings back the cellar list and the cork's row. The pour notes were never in it.

import Foundation
import SwiftData
import SwiftUI

@Model
final class CellarListing {
    var wineName: String
    var bottles: Int
    var stopperLot: String
    var listPriceEuros: Decimal

    init(wineName: String, bottles: Int, stopperLot: String, listPriceEuros: Decimal) {
        self.wineName = wineName
        self.bottles = bottles
        self.stopperLot = stopperLot
        self.listPriceEuros = listPriceEuros
    }
}

@Model
final class PourNote {
    var tableNumber: Int
    var glasses: Int
    var remark: String

    init(tableNumber: Int, glasses: Int, remark: String) {
        self.tableNumber = tableNumber
        self.glasses = glasses
        self.remark = remark
    }
}

struct MorningFolderSummary: Equatable, Sendable {
    let listings: [String]
    let corkRows: [Int]
    let pourNotes: Int
}

struct CorkFolder {
    static let fileTypes: [any PersistentModel.Type] = [CellarListing.self, BarkTally.self]
    static let eveningTypes: [any PersistentModel.Type] = [PourNote.self]
    static var types: [any PersistentModel.Type] { fileTypes + eveningTypes }

    let ledgerURL: URL

    func openFolder() throws -> ModelContainer {
        try ModelContainer(
            for: Schema(Self.types),
            configurations: [
                ModelConfiguration("graca-cellar", schema: Schema(Self.fileTypes), url: ledgerURL),
                ModelConfiguration("graca-evening", schema: Schema(Self.eveningTypes), isStoredInMemoryOnly: true)
            ]
        )
    }

    func layOutMorning() throws -> MorningFolderSummary {
        do {
            let context = ModelContext(try openFolder())
            context.insert(CellarListing(wineName: "Vale Escuro Vintage 2022", bottles: 2, stopperLot: "RV-2603-A", listPriceEuros: 95))
            context.insert(BarkTally(
                treeRow: 14,
                stripperName: "Joaquim Pires",
                arrobas: 42,
                strippedOn: GregorianDay.date(year: 2025, month: 7, day: 14, timeZoneIdentifier: "Europe/Lisbon")
            ))
            [(4, 2, "Opened at 20:10"), (7, 3, "Second glass with the queijada")]
                .map { PourNote(tableNumber: $0, glasses: $1, remark: $2) }
                .forEach(context.insert)
            try context.save()
        }
        return try summary(of: openFolder())
    }

    func summary(of container: ModelContainer) throws -> MorningFolderSummary {
        let context = ModelContext(container)
        let listings = try context.fetch(FetchDescriptor<CellarListing>())
        return MorningFolderSummary(
            listings: listings.map { "\($0.wineName) × \($0.bottles), stoppers \($0.stopperLot)" },
            corkRows: try context.fetch(FetchDescriptor<BarkTally>()).map(\.treeRow),
            pourNotes: try context.fetchCount(FetchDescriptor<PourNote>())
        )
    }
}

struct CellarListingScreen: View {
    @State private var folder = CorkFolder(ledgerURL: ScratchFolder.storeURL(named: "graca-cellar"))
    @State private var summary: MorningFolderSummary?
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 13",
            title: "Lisbon morning folder",
            situation: "On 9 May 2026 Marta Lobo lays out the morning folder at Tasca da Graça in Lisbon. The cellar list and the cork's row card go in the file. Last night's pour notes were jotted in memory.",
            teaches: [
                "One container can join a store file and an in-memory store, each for its own models.",
                "Reopening the file brings back the cellar list and the cork's row. The pour notes were never in it."
            ]
        ) {
            if let summary {
                Section("Cellar file, reopened") {
                    ForEach(summary.listings, id: \.self) { Text($0) }
                    LabeledContent("Cork from row", value: summary.corkRows.map(String.init).joined(separator: ", "))
                    LabeledContent("Pour notes", value: "\(summary.pourNotes)")
                }
                Section {
                    Text("The chain began on row 14 at Herdade do Sobral, ten months ago.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("Lay out the morning folder") {
                    do { summary = try folder.layOutMorning() } catch { failure = error.localizedDescription }
                }
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
    }
}
