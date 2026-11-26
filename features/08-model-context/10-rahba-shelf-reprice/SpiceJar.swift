// Feature: ModelContext
// Slot 10 — Rahba shelf reprice
// Teaches:
// - enumerate walks a fetch in batches and hands each jar to a closure.
// - Edits made during the walk wait for an explicit save.

import SwiftData
import SwiftUI

@Model
final class SpiceJar {
    var jarName: String
    var priceDirhams: Int
    var containsArgan: Bool

    init(jarName: String, priceDirhams: Int, containsArgan: Bool) {
        self.jarName = jarName
        self.priceDirhams = priceDirhams
        self.containsArgan = containsArgan
    }
}

struct RepriceSlip: Equatable {
    var jarsWalked = 0
    var batchesOf: Int
}

enum RahbaShelf {
    static var opening: KeyValuePairs<String, (price: Int, argan: Bool)> { [
        "Amlou, 250 g": (60, true),
        "Culinary argan oil, 250 ml": (120, true),
        "Ras el hanout, 100 g": (35, false),
        "Argan and honey soap": (25, true),
        "Saffron, 1 g": (40, false)
    ] }

    static func stock(_ context: ModelContext) throws {
        for (name, entry) in opening {
            context.insert(SpiceJar(jarName: name, priceDirhams: entry.price, containsArgan: entry.argan))
        }
        try context.save()
    }

    static func raiseArganPrices(by dirhams: Int, in context: ModelContext, batchSize: Int = 2) throws -> RepriceSlip {
        var slip = RepriceSlip(batchesOf: batchSize)
        let arganJars = FetchDescriptor<SpiceJar>(
            predicate: #Predicate { $0.containsArgan },
            sortBy: [SortDescriptor(\.jarName)]
        )
        try context.enumerate(arganJars, batchSize: batchSize) { jar in
            jar.priceDirhams += dirhams
            slip.jarsWalked += 1
        }
        return slip
    }
}

struct SpiceJarScreen: View {
    var body: some View {
        ShelfRepriceDesk().inMemoryStore(for: SpiceJar.self)
    }
}

private struct ShelfRepriceDesk: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SpiceJar.jarName) private var jars: [SpiceJar]
    @State private var slip: RepriceSlip?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 10",
            title: "Rahba shelf reprice",
            situation: "On 16 October 2026 Hamid Ouazzani unpacks the Zitoun soaps and the Amazir oil at his spice shop on Rahba Kedima in Marrakech. Argan cost more this season, so every jar with argan goes up 10 dirhams.",
            teaches: [
                "enumerate walks a fetch in batches and hands each jar to a closure.",
                "Edits made during the walk wait for an explicit save."
            ]
        ) {
            Section("Shelf") {
                ForEach(jars) { jar in
                    LabeledContent(jar.jarName, value: "\(jar.priceDirhams) MAD\(jar.containsArgan ? " · argan" : "")")
                }
            }
            Section {
                if jars.isEmpty {
                    Button("Stock the shelf") { try? RahbaShelf.stock(modelContext) }
                } else if let slip {
                    Text("Walked \(slip.jarsWalked) jars in batches of \(slip.batchesOf) · hasChanges \(String(modelContext.hasChanges))")
                    Button("Save the new prices") { try? modelContext.save() }
                } else {
                    Button("Raise argan jars by 10 MAD") {
                        slip = try? RahbaShelf.raiseArganPrices(by: 10, in: modelContext)
                    }
                }
            }
        }
    }
}
