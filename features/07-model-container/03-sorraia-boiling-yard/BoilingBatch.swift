// Feature: ModelContainer and ModelConfiguration
// Slot 03 — Sorraia boiling yard
// Teaches:
// - Naming one model brings every model it relates to into the container's schema.
// - The boiled planks can be fetched though the container was opened for the batch.

import SwiftData
import SwiftUI

@Model
final class BoilingBatch {
    var batchCode: String
    var boilerName: String
    var minutesInWater: Int
    @Relationship(deleteRule: .cascade, inverse: \BoiledPlank.batch)
    var planks: [BoiledPlank] = []

    init(batchCode: String, boilerName: String, minutesInWater: Int) {
        self.batchCode = batchCode
        self.boilerName = boilerName
        self.minutesInWater = minutesInWater
    }
}

@Model
final class BoiledPlank {
    var plankCode: String
    var thicknessMillimetres: Int
    var batch: BoilingBatch?

    init(plankCode: String, thicknessMillimetres: Int) {
        self.plankCode = plankCode
        self.thicknessMillimetres = thicknessMillimetres
    }
}

enum SorraiaYard {
    static func openBoilingBook() throws -> ModelContainer {
        try ModelContainer(for: BoilingBatch.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}

struct BoilingBatchScreen: View {
    @State private var opened = Result { try SorraiaYard.openBoilingBook() }

    var body: some View {
        if case .success(let container) = opened {
            BoilingYardDesk(schema: container.schema).modelContainer(container)
        } else if case .failure(let error) = opened {
            Text(error.localizedDescription).foregroundStyle(.red)
        }
    }
}

private struct BoilingYardDesk: View {
    let schema: Schema
    @Environment(\.modelContext) private var modelContext
    @Query private var planks: [BoiledPlank]

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 03",
            title: "Sorraia boiling yard",
            situation: "On 9 February 2026, after the winter rest, Ana Ribeiro of Corticeira do Sorraia boils stack P-14 as batch C-14: an hour in the vat, then the planks are pressed flat.",
            teaches: [
                "Naming one model brings every model it relates to into the container's schema.",
                "The boiled planks can be fetched though the container was opened for the batch."
            ]
        ) {
            Section("Schema the container opened") {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                    GridRow {
                        Text("Entity").bold()
                        Text("Attributes").bold()
                        Text("Relationships").bold()
                    }
                    ForEach(schema.entities.sorted { $0.name < $1.name }, id: \.name) { entity in
                        GridRow {
                            Text(entity.name).monospaced()
                            Text(entity.attributes.map(\.name).sorted().joined(separator: ", "))
                            Text(entity.relationships.map(\.name).sorted().joined(separator: ", "))
                        }
                    }
                }
                .font(.callout)
            }
            Section("Planks out of the vat") {
                ForEach(planks.sorted { $0.plankCode < $1.plankCode }) { plank in
                    LabeledContent(plank.plankCode, value: "\(plank.thicknessMillimetres) mm · \(plank.batch?.batchCode ?? "no batch")")
                }
                Button("Boil batch C-14") {
                    let batch = BoilingBatch(batchCode: "C-14", boilerName: "Ana Ribeiro", minutesInWater: 60)
                    modelContext.insert(batch)
                    batch.planks = [32, 34, 29].enumerated().map { offset, millimetres in
                        BoiledPlank(plankCode: "C-14-\(offset + 1)", thicknessMillimetres: millimetres)
                    }
                }
                .disabled(!planks.isEmpty)
            }
        }
    }
}
