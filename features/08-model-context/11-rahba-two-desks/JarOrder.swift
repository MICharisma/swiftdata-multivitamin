// Feature: ModelContext
// Slot 11 — Rahba two desks
// Teaches:
// - Two contexts on one container each hold their own copy of a saved jar order.
// - Saving in one context does not rewrite the other context's held object until that context fetches again.

import SwiftData
import SwiftUI

@Model
final class JarOrder {
    var customerName: String
    var jarName: String
    var jars: Int

    init(customerName: String, jarName: String, jars: Int) {
        self.customerName = customerName
        self.jarName = jarName
        self.jars = jars
    }
}

struct DeskReading: Equatable {
    let counterJars: Int
    let heldBackDesk: Int
    let refetchBackDesk: Int
}

enum RahbaDesks {
    static func openMorningOrder(in counter: ModelContext) throws -> PersistentIdentifier {
        let order = JarOrder(customerName: "Nadia Benjelloun", jarName: "Culinary argan oil, 250 ml", jars: 4)
        counter.insert(order)
        try counter.save()
        return order.persistentModelID
    }

    static func sellTwoFromCounter(counter: ModelContext, backDesk: ModelContext, orderID: PersistentIdentifier) throws -> DeskReading {
        guard let counterOrder: JarOrder = counter.registeredModel(for: orderID) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        let held = try backDesk.fetch(FetchDescriptor<JarOrder>()).first!
        counterOrder.jars -= 2
        try counter.save()
        let refetch = try backDesk.fetch(FetchDescriptor<JarOrder>()).first!
        return DeskReading(counterJars: counterOrder.jars, heldBackDesk: held.jars, refetchBackDesk: refetch.jars)
    }
}

struct JarOrderScreen: View {
    var body: some View {
        TwoDesksDesk().inMemoryStore(for: JarOrder.self)
    }
}

private struct TwoDesksDesk: View {
    @Environment(\.modelContext) private var modelContext
    @State private var reading: DeskReading?
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 11",
            title: "Rahba two desks",
            situation: "On 17 October 2026 Hamid takes Nadia Benjelloun's order for four bottles of culinary argan at the Rahba Kedima counter. His nephew at the back desk has the same order open while Hamid sells two of them.",
            teaches: [
                "Two contexts on one container each hold their own copy of a saved jar order.",
                "Saving in one context does not rewrite the other context's held object until that context fetches again."
            ]
        ) {
            if let reading {
                Section("After the sale") {
                    LabeledContent("Counter", value: "\(reading.counterJars) jars")
                    LabeledContent("Back desk, held object", value: "\(reading.heldBackDesk) jars")
                    LabeledContent("Back desk, refetch", value: "\(reading.refetchBackDesk) jars")
                }
            } else {
                Button("Sell two from the counter") {
                    do {
                        let orderID = try RahbaDesks.openMorningOrder(in: modelContext)
                        let backDesk = ModelContext(modelContext.container)
                        reading = try RahbaDesks.sellTwoFromCounter(counter: modelContext, backDesk: backDesk, orderID: orderID)
                    } catch {
                        failure = error.localizedDescription
                    }
                }
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
    }
}
