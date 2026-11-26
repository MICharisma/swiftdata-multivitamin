// Feature: ModelContainer and ModelConfiguration
// Slot 12 — Bonfim till and stockroom
// Teaches:
// - Two containers can open the same store file.
// - A model already held in one container does not refresh when the other container saves; a new context does.

import Foundation
import SwiftData
import SwiftUI

@Model
final class StockCard {
    var bottleName: String
    var bottlesOnHand: Int
    var lastCountedBy: String

    init(bottleName: String, bottlesOnHand: Int, lastCountedBy: String) {
        self.bottleName = bottleName
        self.bottlesOnHand = bottlesOnHand
        self.lastCountedBy = lastCountedBy
    }
}

struct BonfimStockFile {
    let url: URL

    func openContainer() throws -> ModelContainer {
        try ModelContainer(for: StockCard.self, configurations: ModelConfiguration(url: url))
    }

    static func read<Value>(_ field: KeyPath<StockCard, Value>, through container: ModelContainer) throws -> Value? {
        try ModelContext(container).fetch(FetchDescriptor<StockCard>()).first?[keyPath: field]
    }
}

struct StockroomReading: Equatable {
    var heldCard: Int
    var newContext: Int
    var countedBy: String?
}

enum BonfimCounters {
    /// The till and the stockroom each open their own container on the shop's file.
    static func sellTwoBottles(in file: BonfimStockFile) throws -> StockroomReading {
        let till = try file.openContainer()
        let stockroom = try file.openContainer()

        let tillContext = ModelContext(till)
        tillContext.insert(StockCard(bottleName: "Vale Escuro Vintage 2022", bottlesOnHand: 6, lastCountedBy: "Rui Teixeira"))
        try tillContext.save()

        let stockroomContext = ModelContext(stockroom)
        guard let heldCard = try stockroomContext.fetch(FetchDescriptor<StockCard>()).first,
              let tillCard = try tillContext.fetch(FetchDescriptor<StockCard>()).first else {
            throw CocoaError(.fileReadNoSuchFile)
        }

        tillCard.bottlesOnHand -= 2
        tillCard.lastCountedBy = "Till, sale to Tasca da Graça"
        try tillContext.save()

        return StockroomReading(
            heldCard: heldCard.bottlesOnHand,
            newContext: try BonfimStockFile.read(\.bottlesOnHand, through: stockroom) ?? 0,
            countedBy: try BonfimStockFile.read(\.lastCountedBy, through: stockroom)
        )
    }
}

struct StockCardScreen: View {
    @State private var file = BonfimStockFile(url: ScratchFolder.storeURL(named: "bonfim-stock"))
    @State private var reading: StockroomReading?
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 12",
            title: "Bonfim till and stockroom",
            situation: "On 5 May 2026 Marta Lobo of Tasca da Graça buys two bottles of Vale Escuro 2022 at the Bonfim till. The stockroom laptop has the same stock file open in its own container.",
            teaches: [
                "Two containers can open the same store file.",
                "A model already held in one container does not refresh when the other container saves; a new context does."
            ]
        ) {
            if let reading {
                Section("Stockroom") {
                    LabeledContent("Card it already held", value: "\(reading.heldCard) bottles")
                    LabeledContent("New context", value: "\(reading.newContext) bottles")
                    LabeledContent("Last counted by", value: reading.countedBy ?? "No card")
                }
            } else {
                Button("Ring up two bottles") {
                    do { reading = try BonfimCounters.sellTwoBottles(in: file) }
                    catch { failure = error.localizedDescription }
                }
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
    }
}
