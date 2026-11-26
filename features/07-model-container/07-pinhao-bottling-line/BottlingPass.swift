// Feature: ModelContainer and ModelConfiguration
// Slot 07 — Pinhão bottling line
// Teaches:
// - Two containers that name the same in-memory configuration share that store.
// - A different configuration name opens a separate empty store.

import SwiftData
import SwiftUI

@Model
final class BottlingPass {
    var station: String
    var bottleCount: Int
    var stopperLot: String

    init(station: String, bottleCount: Int, stopperLot: String) {
        self.station = station
        self.bottleCount = bottleCount
        self.stopperLot = stopperLot
    }
}

enum PinhaoLine {
    static func openStation(storeName: String) throws -> ModelContainer {
        try ModelContainer(
            for: BottlingPass.self,
            configurations: ModelConfiguration(storeName, isStoredInMemoryOnly: true)
        )
    }

    static func count<Model: PersistentModel>(_ type: Model.Type, in container: ModelContainer) throws -> Int {
        try ModelContext(container).fetchCount(FetchDescriptor<Model>())
    }

    /// The filler saves one pass, then every station counts what it can see.
    static func runLine() throws -> [StationReading] {
        let filler = try openStation(storeName: "pinhao-line")
        let context = ModelContext(filler)
        context.insert(BottlingPass(station: "Filler", bottleCount: 1_200, stopperLot: "RV-2603-A"))
        try context.save()

        let corker = try openStation(storeName: "pinhao-line")
        let labels = try openStation(storeName: "pinhao-labels")
        return try [("Filler", filler), ("Corker", corker), ("Label table", labels)].map { station, container in
            StationReading(station: station, passes: try count(BottlingPass.self, in: container))
        }
    }
}

struct StationReading: Hashable {
    let station: String
    let passes: Int
}

struct BottlingPassScreen: View {
    @State private var counts: [StationReading] = []
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 07",
            title: "Pinhão bottling line",
            situation: "On 6 April 2026 Tiago Rebelo bottles the 2022 vintage at Quinta do Vale Escuro in Pinhão, using the RV-2603-A stoppers. The filler and the corker each open a container on an in-memory store named pinhao-line. The label table opens one named pinhao-labels.",
            teaches: [
                "Two containers that name the same in-memory configuration share that store.",
                "A different configuration name opens a separate empty store."
            ]
        ) {
            Section("Stations") {
                ForEach(counts, id: \.station) { row in
                    LabeledContent(row.station, value: "\(row.passes) passes visible")
                }
                Button("Run the filler, then ask each station") { runLine() }
                    .disabled(!counts.isEmpty)
                if let failure { Text(failure).foregroundStyle(.red) }
            }
        }
    }

    private func runLine() {
        do { counts = try PinhaoLine.runLine() } catch { failure = error.localizedDescription }
    }
}
