// Feature: ModelContext
// Slot 05 — Essaouira press autosave
// Teaches:
// - Both the main context and a ModelContext you make start with autosave on.
// - Setting autosaveEnabled to false makes the press book wait for an explicit save.

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
    @State private var defaults: AutosaveFlags?
    @State private var pressed = false
    @State private var filedBeforeSave = -1

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 05",
            title: "Essaouira press autosave",
            situation: "On 9 October 2026 the Tifawin roast reaches Huilerie Amazir in Essaouira. Youssef Bennani presses 22 kilos of roasted kernels into 10 litres of oil. The desk turns autosave off before the run is entered.",
            teaches: [
                "Both the main context and a ModelContext you make start with autosave on.",
                "Setting autosaveEnabled to false makes the press book wait for an explicit save."
            ]
        ) {
            Section("Defaults before this desk changes them") {
                if let defaults {
                    LabeledContent("Main context autosaves", value: String(defaults.mainContext))
                    LabeledContent("A context you make autosaves", value: String(defaults.madeContext))
                }
            }
            Section("Press book") {
                LabeledContent("This context autosaves", value: String(modelContext.autosaveEnabled))
                Button("Press run AM-1009 with autosave off") {
                    modelContext.autosaveEnabled = false
                    modelContext.insert(PressRun(runCode: "AM-1009", pressOperator: "Youssef Bennani", roastedKilos: 22, oilLitres: 10))
                    filedBeforeSave = (try? modelContext.freshCount(PressRun.self)) ?? 0
                    pressed = true
                }
                .disabled(pressed)
                if filedBeforeSave >= 0 {
                    LabeledContent("Filed before save", value: "\(filedBeforeSave)")
                    Button("Save the press run") {
                        try? modelContext.save()
                        filedBeforeSave = (try? modelContext.freshCount(PressRun.self)) ?? 0
                    }
                }
            }
        }
        .onAppear {
            defaults = AutosaveFlags(modelContext.container)
        }
    }
}
