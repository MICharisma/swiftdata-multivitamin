// Feature: ModelContext
// Slot 04 — Tifawin scorched pan
// Teaches:
// - rollback() drops an unsaved insert from the context.
// - The object keeps the values it had. modelContext on that object becomes nil.

import SwiftData
import SwiftUI

@Model
final class PanBatch {
    var batchCode: String
    var kernelKilos: Double
    var outcome: String

    init(batchCode: String, kernelKilos: Double, outcome: String) {
        self.batchCode = batchCode
        self.kernelKilos = kernelKilos
        self.outcome = outcome
    }
}

/// What the desk can still see of the scorched batch after the rollback.
struct ScorchedReading: Equatable {
    let contextCount: Int
    let stillAttached: Bool
    let hasChanges: Bool
    let kilosOnTheCard: Double
}

extension ModelContext {
    func discardUnsaved(_ batch: PanBatch) throws -> ScorchedReading {
        rollback()
        return ScorchedReading(
            contextCount: try fetchCount(FetchDescriptor<PanBatch>()),
            stillAttached: batch.modelContext != nil,
            hasChanges: hasChanges,
            kilosOnTheCard: batch.kernelKilos
        )
    }
}

struct PanBatchScreen: View {
    var body: some View {
        ScorchedPanDesk().inMemoryStore(for: PanBatch.self)
    }
}

private struct ScorchedPanDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var pendingBatch: PanBatch?
    @State private var reading: ScorchedReading?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 04",
            title: "Tifawin scorched pan",
            situation: "Later on 7 October Khadija starts a second pan, TF-0416-R, with 6 kilos. The fire flares and the kernels scorch. The batch was never saved, so she throws out the card with the kernels.",
            teaches: [
                "rollback() drops an unsaved insert from the context.",
                "The object keeps the values it had. modelContext on that object becomes nil."
            ]
        ) {
            if let reading {
                Section("After rollback") {
                    LabeledContent("Batches in the context", value: "\(reading.contextCount)")
                    LabeledContent("Card still attached", value: reading.stillAttached ? "Yes" : "No")
                    LabeledContent("hasChanges", value: String(reading.hasChanges))
                    LabeledContent("Kilos on the loose card", value: reading.kilosOnTheCard.formatted())
                }
            } else if let pendingBatch {
                Section("Unsaved") {
                    LabeledContent(pendingBatch.batchCode, value: "\(pendingBatch.kernelKilos.formatted()) kg")
                    Button("Throw out the scorched batch", role: .destructive) {
                        reading = try? modelContext.discardUnsaved(pendingBatch)
                    }
                }
            } else {
                Button("Start the second pan") {
                    let batch = PanBatch(batchCode: "TF-0416-R", kernelKilos: 6, outcome: "Scorched")
                    modelContext.insert(batch)
                    pendingBatch = batch
                }
            }
        }
    }
}
