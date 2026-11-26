// Feature: ModelContainer and ModelConfiguration
// Slot 06 — Feira print room
// Teaches:
// - A ModelConfiguration is a value. Building one creates no file.
// - Its name, url, and flags say where a container would put the store.

import Foundation
import SwiftData
import SwiftUI

@Model
final class BrandProof {
    var brandLine: String
    var inkColour: String
    var stopperLot: String

    init(brandLine: String, inkColour: String, stopperLot: String) {
        self.brandLine = brandLine
        self.inkColour = inkColour
        self.stopperLot = stopperLot
    }
}

enum PrintRoomBooks {
    static var proofTray: ModelConfiguration {
        ModelConfiguration("feira-proof-tray", schema: Schema([BrandProof.self]), isStoredInMemoryOnly: true)
    }

    static var floorBook: ModelConfiguration {
        ModelConfiguration("feira-print", schema: Schema([BrandProof.self]))
    }

    static func archiveBook(at url: URL) -> ModelConfiguration {
        ModelConfiguration("feira-print-archive", schema: Schema([BrandProof.self]), url: url, allowsSave: false)
    }
}

struct ConfigurationCard: Identifiable {
    let id: String
    let fileName: String
    let inMemory: Bool
    let allowsSave: Bool
    let modelNames: String

    init(_ configuration: ModelConfiguration) {
        id = configuration.name
        fileName = configuration.url.lastPathComponent
        inMemory = configuration.isStoredInMemoryOnly
        allowsSave = configuration.allowsSave
        modelNames = configuration.schema?.entities.map(\.name).joined(separator: ", ") ?? "Whole container"
    }
}

struct BrandProofScreen: View {
    @State private var archiveURL = ScratchFolder.storeURL(named: "feira-print-archive")
    @State private var proofs: [String] = []

    private var cards: [ConfigurationCard] {
        [PrintRoomBooks.proofTray, PrintRoomBooks.floorBook, PrintRoomBooks.archiveBook(at: archiveURL)]
            .map(ConfigurationCard.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("On 12 March 2026 Carla Neves brands the RV-2603-A stoppers for Quinta do Vale Escuro. She keeps three books in mind: a proof tray, the floor book, and a read-only archive. Only the proof tray is opened.")
                .foregroundStyle(.secondary)
            Table(cards) {
                TableColumn("Name", value: \.id)
                TableColumn("File", value: \.fileName)
                TableColumn("In memory") { Text($0.inMemory ? "Yes" : "No") }
                TableColumn("Saves") { Text($0.allowsSave ? "Yes" : "No") }
                TableColumn("Models", value: \.modelNames)
            }
            .frame(minHeight: 140)
            LabeledContent("Archive file exists", value: FileManager.default.fileExists(atPath: archiveURL.path) ? "Yes" : "No")
            Button("Pull a proof on the tray") { pullProof() }
                .disabled(!proofs.isEmpty)
            ForEach(proofs, id: \.self) { Text($0) }
            Text("Teaches: a configuration is a value; its name, url, and flags say where a container would put the store.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Feira print room")
    }

    private func pullProof() {
        guard let tray = try? ModelContainer(for: Schema([BrandProof.self]), configurations: [PrintRoomBooks.proofTray]) else { return }
        let context = ModelContext(tray)
        context.insert(BrandProof(brandLine: "Quinta do Vale Escuro · 2022", inkColour: "Burnt umber", stopperLot: "RV-2603-A"))
        try? context.save()
        proofs = (try? context.fetch(FetchDescriptor<BrandProof>()).map { "\($0.brandLine) in \($0.inkColour)" }) ?? []
    }
}
