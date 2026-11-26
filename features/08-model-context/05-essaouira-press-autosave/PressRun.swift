// Feature: ModelContext
// Slot 05 — Essaouira press autosave
// Teaches:
// - The main context from modelContainer(for:inMemory:) autosaves by default.
// - A ModelContext you make yourself starts with autosave off.

import SwiftData
import SwiftUI

@Model
final class PressRun {
    var runCode: String
    var pressOperator: String
    var roastedKilos: Double
    var oilLitres: Double

    init(runCode: String, pressOperator: String, roastedKilos: Double, oilLitres: Double) {
        self.runCode = runCode
        self.pressOperator = pressOperator
        self.roastedKilos = roastedKilos
        self.oilLitres = oilLitres
    }
}

struct AutosaveFlags: Equatable {
    let mainContext: Bool
    let madeContext: Bool

    @MainActor
    init(_ container: ModelContainer) {
        mainContext = container.mainContext.autosaveEnabled
        madeContext = ModelContext(container).autosaveEnabled
    }
}

struct PressRunScreen: View {
    var body: some View {
        PressAutosaveDesk()
            .modelContainer(for: PressRun.self, inMemory: true)
    }
}

private struct PressAutosaveDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var pressed = false

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 05",
            title: "Essaouira press autosave",
            situation: "On 9 October 2026 the Tifawin roast reaches Huilerie Amazir in Essaouira. Youssef Bennani presses 22 kilos of roasted kernels into 10 litres of oil. Nobody at the press taps save.",
            teaches: [
                "The main context from modelContainer(for:inMemory:) autosaves by default.",
                "A ModelContext you make yourself starts with autosave off."
            ]
        ) {
            Section("Contexts") {
                let flags = AutosaveFlags(modelContext.container)
                LabeledContent("Main context autosaves", value: String(flags.mainContext))
                LabeledContent("A context you make autosaves", value: String(flags.madeContext))
            }
            Section("Press book") {
                Button("Press run AM-1009") {
                    modelContext.insert(PressRun(runCode: "AM-1009", pressOperator: "Youssef Bennani", roastedKilos: 22, oilLitres: 10))
                    pressed = true
                }
                .disabled(pressed)
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    LabeledContent("Filed, read from a new context") {
                        Text("\((try? modelContext.freshCount(PressRun.self)) ?? 0) runs at \(timeline.date.formatted(date: .omitted, time: .standard))")
                    }
                }
            }
        }
    }
}
