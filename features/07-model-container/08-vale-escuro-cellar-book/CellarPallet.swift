// Feature: ModelContainer and ModelConfiguration
// Slot 08 — Vale Escuro cellar book
// Teaches:
// - A ModelContainer is Sendable. An actor can keep one and make its own contexts.
// - Saves from those contexts land in the store the main context reads.

import SwiftData
import SwiftUI

@Model
final class CellarPallet {
    var palletCode: String
    var cellarAisle: String
    var cases: Int
    var stopperLot: String

    init(_ tally: PalletTally) {
        palletCode = tally.palletCode
        cellarAisle = tally.cellarAisle
        cases = tally.cases
        stopperLot = tally.stopperLot
    }
}

struct PalletTally: Sendable {
    let palletCode: String
    let cellarAisle: String
    let cases: Int
    var stopperLot = "RV-2603-A"
}

actor AisleCounter {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func file(_ tallies: [PalletTally]) throws -> Int {
        let context = ModelContext(container)
        tallies.map(CellarPallet.init).forEach(context.insert)
        try context.save()
        return tallies.reduce(0) { $0 + $1.cases }
    }
}

enum ValeEscuroCellar {
    static let eastAisle = [
        PalletTally(palletCode: "VE-22-01", cellarAisle: "East", cases: 60),
        PalletTally(palletCode: "VE-22-02", cellarAisle: "East", cases: 60)
    ]
    static let westAisle = [
        PalletTally(palletCode: "VE-22-03", cellarAisle: "West", cases: 60),
        PalletTally(palletCode: "VE-22-04", cellarAisle: "West", cases: 45)
    ]

    /// Both aisles are counted at once, each by its own actor on the same container.
    static func countBothAisles(into container: ModelContainer) async throws -> Int {
        async let east = AisleCounter(container: container).file(eastAisle)
        async let west = AisleCounter(container: container).file(westAisle)
        return try await east + west
    }
}

struct CellarPalletScreen: View {
    var body: some View {
        CellarBookDesk().inMemoryStore(for: CellarPallet.self)
    }
}

private struct CellarBookDesk: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CellarPallet.palletCode) private var pallets: [CellarPallet]
    @State private var countedCases: Int?
    @State private var counting = false
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 08",
            title: "Vale Escuro cellar book",
            situation: "On 7 April 2026 the corked 2022 vintage goes down to the cellar at Quinta do Vale Escuro. Two cellar hands count the east and west aisles at the same time, while Tiago watches the book from the office.",
            teaches: [
                "A ModelContainer is Sendable. An actor can keep one and make its own contexts.",
                "Saves from those contexts land in the store the main context reads."
            ]
        ) {
            Section("Cellar book") {
                ForEach(pallets) { pallet in
                    LabeledContent(pallet.palletCode, value: "\(pallet.cellarAisle) · \(pallet.cases) cases")
                }
                if let countedCases {
                    LabeledContent("Counted by the actors", value: "\(countedCases) cases")
                }
            }
            Button("Count both aisles") { counting = true }
                .disabled(counting || countedCases != nil)
            if let failure { Text(failure).foregroundStyle(.red) }
        }
        .task(id: counting) {
            guard counting else { return }
            do {
                countedCases = try await ValeEscuroCellar.countBothAisles(into: modelContext.container)
            } catch {
                failure = error.localizedDescription
            }
            counting = false
        }
    }
}
