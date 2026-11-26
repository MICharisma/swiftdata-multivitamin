// Feature: ModelContainer and ModelConfiguration
// Slot 11 — Bonfim shelf books
// Teaches:
// - An enum with associated values can choose the configuration for each place a book lives.
// - The container reports back the configuration it was opened with.

import Foundation
import SwiftData
import SwiftUI

@Model
final class ShelfBottle {
    var bottleName: String
    var vintage: Int
    var priceEuros: Decimal
    var shelf: String

    init(bottleName: String, vintage: Int, priceEuros: Decimal, shelf: String) {
        self.bottleName = bottleName
        self.vintage = vintage
        self.priceEuros = priceEuros
        self.shelf = shelf
    }
}

enum ShelfBook: Hashable {
    case counterScratch
    case shopFile(URL)
    case lodgeCopy(URL)

    var configuration: ModelConfiguration {
        let schema = Schema([ShelfBottle.self])
        return switch self {
        case .counterScratch:
            ModelConfiguration("bonfim-counter", schema: schema, isStoredInMemoryOnly: true)
        case .shopFile(let url):
            ModelConfiguration("bonfim-shelves", schema: schema, url: url)
        case .lodgeCopy(let url):
            ModelConfiguration("sarmento-price-list", schema: schema, url: url, allowsSave: false)
        }
    }

    var title: String {
        switch self {
        case .counterScratch: "Counter scratch pad"
        case .shopFile: "Shop shelf book"
        case .lodgeCopy: "Lodge price list"
        }
    }

    func open() throws -> ModelContainer {
        try ModelContainer(for: Schema([ShelfBottle.self]), configurations: [configuration])
    }
}

enum BonfimShop {
    static func books(shopFile: URL, lodgeFile: URL) -> [ShelfBook] {
        [.counterScratch, .shopFile(shopFile), .lodgeCopy(lodgeFile)]
    }

    static func describe(_ container: ModelContainer) -> String {
        guard let opened = container.configurations.first else { return "No configuration" }
        let place = opened.isStoredInMemoryOnly ? "memory" : opened.url.lastPathComponent
        return "\(opened.name) · \(place) · \(opened.allowsSave ? "saves" : "read only")"
    }
}

struct ShelfBottleScreen: View {
    @State private var shopFile = ScratchFolder.storeURL(named: "bonfim-shelves")
    @State private var lodgeFile = ScratchFolder.storeURL(named: "sarmento-price-list")
    @State private var openedLines: [ShelfBook: String] = [:]

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 11",
            title: "Bonfim shelf books",
            situation: "On 4 May 2026 Rui Teixeira shelves six bottles of Vale Escuro 2022 at Garrafeira do Bonfim in Porto, at 68 euros. He jots on the counter pad, files in the shop book, and reads the Sarmento price list.",
            teaches: [
                "An enum with associated values can choose the configuration for each place a book lives.",
                "The container reports back the configuration it was opened with."
            ]
        ) {
            ForEach(BonfimShop.books(shopFile: shopFile, lodgeFile: lodgeFile), id: \.self) { book in
                Section(book.title) {
                    if let line = openedLines[book] {
                        Text(line).font(.callout.monospaced())
                    } else {
                        Button("Open the \(book.title.lowercased())") { open(book) }
                    }
                }
            }
        }
    }

    private func open(_ book: ShelfBook) {
        if case .lodgeCopy(let url) = book, !FileManager.default.fileExists(atPath: url.path) {
            seedPriceList(at: url)
        }
        openedLines[book] = (try? book.open()).map(BonfimShop.describe) ?? "Did not open"
    }

    private func seedPriceList(at url: URL) {
        guard let lodge = try? ModelContainer(for: ShelfBottle.self, configurations: ModelConfiguration(url: url)) else { return }
        let context = ModelContext(lodge)
        context.insert(ShelfBottle(bottleName: "Vale Escuro Vintage", vintage: 2022, priceEuros: 52, shelf: "Trade price"))
        try? context.save()
    }
}
