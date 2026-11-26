// Feature: ModelContainer and ModelConfiguration
// Slot 05 — Feira punching floor
// Teaches:
// - One container can hold two configurations, each with its own schema and file.
// - Each model is saved to the file whose configuration lists it.

import Foundation
import SwiftData
import SwiftUI

@Model
final class PunchRun {
    var runCode: String
    var operatorName: String
    var stoppersPunched: Int
    var stopperSize: String

    init(runCode: String, operatorName: String, stoppersPunched: Int, stopperSize: String) {
        self.runCode = runCode
        self.operatorName = operatorName
        self.stoppersPunched = stoppersPunched
        self.stopperSize = stopperSize
    }
}

@Model
final class RejectSack {
    var sackCode: String
    var kilos: Double
    var destination: String

    init(sackCode: String, kilos: Double, destination: String) {
        self.sackCode = sackCode
        self.kilos = kilos
        self.destination = destination
    }
}

@resultBuilder
enum StoreShelfBuilder {
    static func buildExpression(_ configuration: ModelConfiguration) -> [ModelConfiguration] {
        [configuration]
    }

    static func buildBlock(_ shelves: [ModelConfiguration]...) -> [ModelConfiguration] {
        shelves.flatMap { $0 }
    }

    static func buildOptional(_ shelf: [ModelConfiguration]?) -> [ModelConfiguration] {
        shelf ?? []
    }
}

struct PunchingFloor {
    let runsURL = ScratchFolder.storeURL(named: "feira-punch-runs")
    let rejectsURL = ScratchFolder.storeURL(named: "feira-reject-sacks")

    @StoreShelfBuilder
    var shelves: [ModelConfiguration] {
        ModelConfiguration("punch-runs", schema: Schema([PunchRun.self]), url: runsURL)
        ModelConfiguration("reject-sacks", schema: Schema([RejectSack.self]), url: rejectsURL)
    }

    func openFloor() throws -> ModelContainer {
        try ModelContainer(for: Schema([PunchRun.self, RejectSack.self]), configurations: shelves)
    }

    /// Opens one file on its own, the way the granulate line reads only the sacks.
    func openShelf<Model: PersistentModel>(_ url: URL, for type: Model.Type) throws -> ModelContainer {
        try ModelContainer(for: type, configurations: ModelConfiguration(url: url))
    }
}

struct PunchRunScreen: View {
    @State private var floor = PunchingFloor()
    @State private var readings: [String] = []
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 05",
            title: "Feira punching floor",
            situation: "On 9 March 2026 Bruno Sá punches 24,000 stoppers of 45 × 24 mm from the C-14 planks. The offcuts go into sack RJ-0309 for the granulate line, which keeps its own book.",
            teaches: [
                "One container can hold two configurations, each with its own schema and file.",
                "Each model is saved to the file whose configuration lists it."
            ]
        ) {
            Section("Configurations") {
                ForEach(floor.shelves, id: \.name) { shelf in
                    LabeledContent(shelf.name, value: shelf.url.lastPathComponent)
                }
            }
            Section("After the shift") {
                Button("Close the punching shift") { closeShift() }
                    .disabled(!readings.isEmpty)
                ForEach(readings, id: \.self) { Text($0) }
                if let failure { Text(failure).foregroundStyle(.red) }
            }
        }
    }

    private func closeShift() {
        do {
            let context = ModelContext(try floor.openFloor())
            context.insert(PunchRun(runCode: "RV-2603-A", operatorName: "Bruno Sá", stoppersPunched: 24_000, stopperSize: "45 × 24 mm"))
            context.insert(RejectSack(sackCode: "RJ-0309", kilos: 31.5, destination: "Granulate line"))
            try context.save()

            let runs = try ModelContext(floor.openShelf(floor.runsURL, for: PunchRun.self)).fetch(FetchDescriptor<PunchRun>())
            let sacks = try ModelContext(floor.openShelf(floor.rejectsURL, for: RejectSack.self)).fetch(FetchDescriptor<RejectSack>())
            readings = runs.map { "\(floor.runsURL.lastPathComponent): \($0.runCode), \($0.stoppersPunched) stoppers" }
                + sacks.map { "\(floor.rejectsURL.lastPathComponent): \($0.sackCode), \($0.kilos) kg" }
        } catch {
            failure = error.localizedDescription
        }
    }
}
