// Feature: ModelContainer and ModelConfiguration
// Slot 01 — Coruche bark tally
// Teaches:
// - A container is opened from a model type and a configuration.
// - An in-memory configuration gives each container its own empty store.

import SwiftData
import SwiftUI

@Model
final class BarkTally {
    var treeRow: Int
    var stripperName: String
    /// One arroba of cork is 15 kilograms on the Sobral scale.
    var arrobas: Double
    var strippedOn: Date

    init(treeRow: Int, stripperName: String, arrobas: Double, strippedOn: Date) {
        self.treeRow = treeRow
        self.stripperName = stripperName
        self.arrobas = arrobas
        self.strippedOn = strippedOn
    }

    var kilos: Double { arrobas * 15 }
}

enum BarkTallyBook {
    static func open() throws -> ModelContainer {
        try ModelContainer(
            for: BarkTally.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}

struct BarkTallyScreen: View {
    @State private var book = Result { try BarkTallyBook.open() }

    var body: some View {
        switch book {
        case .success(let container):
            BarkTallyDesk(storeLine: Self.describe(container))
                .modelContainer(container)
        case .failure(let error):
            Text("The tally book did not open: \(error.localizedDescription)")
                .foregroundStyle(.red)
        }
    }

    private static func describe(_ container: ModelContainer) -> String {
        guard let configuration = container.configurations.first else { return "No configuration" }
        return configuration.isStoredInMemoryOnly ? "In memory · \(configuration.name)" : configuration.url.path
    }
}

private struct BarkTallyDesk: View {
    let storeLine: String
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BarkTally.treeRow) private var tallies: [BarkTally]

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 01",
            title: "Coruche bark tally",
            situation: "On 14 July 2025 Joaquim Pires strips row 14 of the cork oaks at Herdade do Sobral, outside Coruche. Manuel Cardoso weighs the bark on the cart: 42 arrobas.",
            teaches: [
                "A container is opened from a model type and a configuration.",
                "An in-memory configuration gives each container its own empty store."
            ]
        ) {
            Section("Store") {
                LabeledContent("Tally book", value: storeLine)
            }
            Section("Rows stripped") {
                ForEach(tallies) { tally in
                    LabeledContent("Row \(tally.treeRow) · \(tally.stripperName)") {
                        Text("\(tally.arrobas, format: .number) arrobas · \(tally.kilos, format: .number) kg")
                    }
                }
                Button("Weigh Joaquim's cart") {
                    modelContext.insert(BarkTally(
                        treeRow: 14,
                        stripperName: "Joaquim Pires",
                        arrobas: 42,
                        strippedOn: GregorianDay.date(year: 2025, month: 7, day: 14, timeZoneIdentifier: "Europe/Lisbon")
                    ))
                }
                .disabled(!tallies.isEmpty)
            }
        }
    }
}
