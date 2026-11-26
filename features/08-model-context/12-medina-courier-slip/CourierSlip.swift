// Feature: ModelContext
// Slot 12 — Medina courier slip
// Teaches:
// - registeredModel(for:) returns the slip only if this context already holds it.
// - model(for:) materializes the slip from the store when the context does not yet hold it.

import SwiftData
import SwiftUI

@Model
final class CourierSlip {
    var slipCode: String
    var destination: String
    var bottles: Int

    init(slipCode: String, destination: String, bottles: Int) {
        self.slipCode = slipCode
        self.destination = destination
        self.bottles = bottles
    }
}

struct SlipLookups: Equatable {
    let registeredBefore: Bool
    let modelForBottles: Int?
    let registeredAfter: Bool
    let filedAfterVoid: Int
}

enum MedinaCourier {
    static func lookUp(_ id: PersistentIdentifier, in desk: ModelContext, afterDeletingIn source: ModelContext) throws -> SlipLookups {
        let before: CourierSlip? = desk.registeredModel(for: id)
        let materialized = desk.model(for: id) as? CourierSlip
        let bottles = materialized?.bottles
        let afterMaterialize: CourierSlip? = desk.registeredModel(for: id)

        source.delete(source.model(for: id))
        try source.save()

        return SlipLookups(
            registeredBefore: before != nil,
            modelForBottles: bottles,
            registeredAfter: afterMaterialize != nil,
            filedAfterVoid: try ModelContext(desk.container).fetchCount(FetchDescriptor<CourierSlip>())
        )
    }
}

struct CourierSlipScreen: View {
    var body: some View {
        CourierDesk().inMemoryStore(for: CourierSlip.self)
    }
}

private struct CourierDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var lookups: SlipLookups?
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 12",
            title: "Medina courier slip",
            situation: "On 18 October 2026 a courier from Bab Doukkala collects two bottles for Riad des Oliviers. Hamid files slip CK-18, then the warehouse desk looks it up by its persistent identifier before the slip is voided.",
            teaches: [
                "registeredModel(for:) returns the slip only if this context already holds it.",
                "model(for:) materializes the slip from the store when the context does not yet hold it."
            ]
        ) {
            if let lookups {
                Section("Warehouse desk") {
                    LabeledContent("registeredModel before", value: lookups.registeredBefore ? "Held" : "Nil")
                    LabeledContent("model(for:) bottles", value: lookups.modelForBottles.map(String.init) ?? "Nil")
                    LabeledContent("registeredModel after", value: lookups.registeredAfter ? "Held" : "Nil")
                    LabeledContent("Filed after void", value: "\(lookups.filedAfterVoid)")
                }
            } else {
                Button("File the slip and ask the warehouse desk") {
                    do {
                        let slip = CourierSlip(slipCode: "CK-18", destination: "Riad des Oliviers", bottles: 2)
                        modelContext.insert(slip)
                        try modelContext.save()
                        let warehouse = ModelContext(modelContext.container)
                        lookups = try MedinaCourier.lookUp(slip.persistentModelID, in: warehouse, afterDeletingIn: modelContext)
                    } catch {
                        failure = error.localizedDescription
                    }
                }
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
    }
}
