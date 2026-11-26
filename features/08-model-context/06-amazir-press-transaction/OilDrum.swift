// Feature: ModelContext
// Slot 06 — Amazir press transaction
// Teaches:
// - transaction runs its closure and saves what the closure changed.
// - If the transaction throws, nothing from that closure is saved.

import SwiftData
import SwiftUI

@Model
final class OilDrum {
    var drumCode: String
    var litres: Double
    var pressRun: String

    init(drumCode: String, litres: Double, pressRun: String) {
        self.drumCode = drumCode
        self.litres = litres
        self.pressRun = pressRun
    }
}

@Model
final class PressCake {
    var pressRun: String
    var kilos: Double
    var destination: String

    init(pressRun: String, kilos: Double, destination: String) {
        self.pressRun = pressRun
        self.kilos = kilos
        self.destination = destination
    }
}

struct DrumScaleJam: Error, CustomStringConvertible {
    let drumCode: String
    var description: String { "The scale jammed under drum \(drumCode)." }
}

enum AmazirPress {
    static func drainRun(_ runCode: String, litres: Double, cakeKilos: Double, in context: ModelContext) throws {
        try context.transaction {
            context.insert(OilDrum(drumCode: "\(runCode)-D1", litres: litres, pressRun: runCode))
            context.insert(PressCake(pressRun: runCode, kilos: cakeKilos, destination: "Goat feed, Ounagha"))
        }
    }

    static func drainOnJammedScale(_ runCode: String, in context: ModelContext) throws {
        try context.transaction {
            context.insert(OilDrum(drumCode: "\(runCode)-D1", litres: 9.5, pressRun: runCode))
            throw DrumScaleJam(drumCode: "\(runCode)-D1")
        }
    }
}

struct OilDrumScreen: View {
    var body: some View {
        PressTransactionDesk().inMemoryStore(for: OilDrum.self, PressCake.self)
    }
}

private struct PressTransactionDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var lines: [String] = []

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 06",
            title: "Amazir press transaction",
            situation: "On 10 October 2026 Youssef drains run AM-1009 into a drum and bags the press cake for a goat farmer in Ounagha. Drum and cake go in the book together. On run AM-1010 the drum scale jams halfway.",
            teaches: [
                "transaction runs its closure and saves what the closure changed.",
                "If the transaction throws, nothing from that closure is saved."
            ]
        ) {
            Section("Press book") {
                Button("Drain AM-1009") {
                    record { try AmazirPress.drainRun("AM-1009", litres: 10, cakeKilos: 12, in: modelContext) }
                }
                Button("Drain AM-1010 on the jammed scale") {
                    record { try AmazirPress.drainOnJammedScale("AM-1010", in: modelContext) }
                }
                ForEach(lines, id: \.self) { Text($0).font(.callout.monospaced()) }
            }
        }
    }

    private func record(_ drain: () throws -> Void) {
        let outcome: String
        do {
            try drain()
            outcome = "saved"
        } catch {
            outcome = "threw: \(error)"
        }
        let drums = (try? modelContext.freshCount(OilDrum.self)) ?? 0
        let cakes = (try? modelContext.freshCount(PressCake.self)) ?? 0
        lines.append("\(outcome) · filed drums \(drums), cakes \(cakes) · hasChanges \(modelContext.hasChanges)")
    }
}
