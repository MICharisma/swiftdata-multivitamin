// Feature: ModelContainer and ModelConfiguration
// Slot 09 — Gaia lodge register
// Teaches:
// - A container can be opened from a Schema value that carries a version.
// - container.schema is that schema, version included.

import SwiftData
import SwiftUI

@Model
final class LodgeEntry {
    var lotCode: String
    var vintage: Int
    var cases: Int
    var lodgeFloor: String

    init(lotCode: String, vintage: Int, cases: Int, lodgeFloor: String) {
        self.lotCode = lotCode
        self.vintage = vintage
        self.cases = cases
        self.lodgeFloor = lodgeFloor
    }
}

enum GaiaRegister {
    static var version: Schema.Version { Schema.Version(2, 1, 0) }

    static var schema: Schema {
        Schema([LodgeEntry.self], version: version)
    }

    static func open() throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            migrationPlan: nil,
            configurations: [ModelConfiguration("gaia-register", isStoredInMemoryOnly: true)]
        )
    }

    static func cases(ofVintage vintage: Int, in entries: [LodgeEntry]) -> Int {
        entries.lazy
            .filter { $0.vintage == vintage }
            .map(\.cases)
            .reduce(0, +)
    }
}

struct LodgeEntryScreen: View {
    @State private var register = Result { try GaiaRegister.open() }

    var body: some View {
        switch register {
        case .success(let container):
            LodgeRegisterDesk(version: container.schema.version).modelContainer(container)
        case .failure(let error):
            Text(error.localizedDescription).foregroundStyle(.red)
        }
    }
}

private struct LodgeRegisterDesk: View {
    let version: Schema.Version
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\LodgeEntry.vintage, order: .reverse), SortDescriptor(\LodgeEntry.lotCode)])
    private var entries: [LodgeEntry]

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 09",
            title: "Gaia lodge register",
            situation: "On 20 April 2026 the Vale Escuro pallets cross the river to Caves Sarmento in Vila Nova de Gaia. Helena Sarmento's register has carried schema version 2.1.0 since the lodge started writing the floor on each entry.",
            teaches: [
                "A container can be opened from a Schema value that carries a version.",
                "container.schema is that schema, version included."
            ]
        ) {
            Section("Register") {
                LabeledContent("Schema version", value: "\(version.major).\(version.minor).\(version.patch)")
                LabeledContent("2022 cases", value: "\(GaiaRegister.cases(ofVintage: 2022, in: entries))")
            }
            Section("Entries") {
                List(entries) { entry in
                    Text("\(entry.lotCode) · \(entry.vintage) · \(entry.cases) cases · \(entry.lodgeFloor)")
                }
                .frame(minHeight: 120)
                Button("Enter the Vale Escuro pallets") {
                    modelContext.insert(LodgeEntry(lotCode: "VE-22", vintage: 2022, cases: 225, lodgeFloor: "Ground floor, north"))
                    modelContext.insert(LodgeEntry(lotCode: "SR-17", vintage: 2017, cases: 40, lodgeFloor: "Upper floor"))
                }
                .disabled(!entries.isEmpty)
            }
        }
    }
}
