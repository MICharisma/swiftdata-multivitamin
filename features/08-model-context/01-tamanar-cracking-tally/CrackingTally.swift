// Feature: ModelContext
// Slot 01 — Tamanar cracking tally
// Teaches:
// - insert puts the tally in the context, and hasChanges turns true.
// - save writes it to the store, and hasChanges turns false.

import SwiftData
import SwiftUI

@Model
final class CrackingTally {
    var crackerName: String
    var kernelKilos: Double
    var crackedOn: Date

    init(crackerName: String, kernelKilos: Double, crackedOn: Date) {
        self.crackerName = crackerName
        self.kernelKilos = kernelKilos
        self.crackedOn = crackedOn
    }
}

struct CrackingTallyScreen: View {
    var body: some View {
        CrackingTallyDesk().inMemoryStore(for: CrackingTally.self)
    }
}

private struct CrackingTallyDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var steps: [String] = []

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 01",
            title: "Tamanar cracking tally",
            situation: "On 5 October 2026 Fadma Aït Brahim cracks argan nuts between two stones at Coopérative Tifawin in Tamanar. By noon she has 9.5 kilos of kernels for the roaster.",
            teaches: [
                "insert puts the tally in the context, and hasChanges turns true.",
                "save writes it to the store, and hasChanges turns false."
            ]
        ) {
            Section("Context") {
                ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                    Text(step).monospaced()
                }
            }
            Section {
                Button("Insert Fadma's tally") {
                    modelContext.insert(CrackingTally(
                        crackerName: "Fadma Aït Brahim",
                        kernelKilos: 9.5,
                        crackedOn: GregorianDay.date(year: 2026, month: 10, day: 5, timeZoneIdentifier: "Africa/Casablanca")
                    ))
                    note("insert")
                }
                .disabled(!steps.isEmpty)
                Button("Save the tally") {
                    do {
                        try modelContext.save()
                        note("save")
                    } catch {
                        steps.append("save threw \(error.localizedDescription)")
                    }
                }
                .disabled(steps.count != 1)
            }
        }
    }

    private func note(_ step: String) {
        let filed = (try? modelContext.freshCount(CrackingTally.self)) ?? 0
        steps.append("\(step): hasChanges \(modelContext.hasChanges), filed \(filed)")
    }
}
