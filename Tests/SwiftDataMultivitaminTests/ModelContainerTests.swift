import Foundation
import SwiftData
import Testing
@testable import SwiftDataMultivitamin

@MainActor
@Suite(.serialized)
struct ModelContainerTests {
    @Test func barkTallyOpensAnInMemoryContainer() throws {
        let container = try BarkTallyBook.open()
        let configuration = try #require(container.configurations.first)
        #expect(configuration.isStoredInMemoryOnly)
        #expect(container.schema.entities.map(\.name) == ["BarkTally"])

        let context = ModelContext(container)
        context.insert(BarkTally(
            treeRow: 14,
            stripperName: "Joaquim Pires",
            arrobas: 42,
            strippedOn: GregorianDay.date(year: 2025, month: 7, day: 14, timeZoneIdentifier: "Europe/Lisbon")
        ))
        try context.save()
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<BarkTally>()) == 1)

        let other = try BarkTallyBook.open()
        #expect(try ModelContext(other).fetchCount(FetchDescriptor<BarkTally>()) == 0)
    }

    @Test func stackBookSurvivesReopeningTheFile() throws {
        let book = SobralStackBook()
        try book.file(CorkStack(
            stackCode: "P-14",
            plankCount: 38,
            yardCorner: "North corner",
            stackedOn: GregorianDay.date(year: 2025, month: 7, day: 18, timeZoneIdentifier: "Europe/Lisbon")
        ))
        let lines = try book.reopenedLines()
        #expect(lines == [StackLine(stackCode: "P-14", plankCount: 38, yardCorner: "North corner")])
        #expect(ScratchFolder.sidecarNames(beside: book.fileURL).contains(book.fileURL.lastPathComponent))
        ScratchFolder.discard(book.fileURL)
    }

    @Test func boilingBookPullsRelatedPlanksIntoTheSchema() throws {
        let container = try SorraiaYard.openBoilingBook()
        #expect(container.schema.entities.map(\.name).sorted() == ["BoiledPlank", "BoilingBatch"])

        let context = ModelContext(container)
        let batch = BoilingBatch(batchCode: "C-14", boilerName: "Ana Ribeiro", minutesInWater: 60)
        context.insert(batch)
        batch.planks = [BoiledPlank(plankCode: "C-14-1", thicknessMillimetres: 32)]
        try context.save()
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<BoiledPlank>()) == 1)
    }

    @Test func readOnlyArchiveRefusesASave() throws {
        let archive = try GradingArchive.season2025()
        let container = try archive.openForReading()
        #expect(container.configurations.allSatisfy { !$0.allowsSave })
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<GradingSheet>()) == 2)

        switch archive.regrade("RV-2507", to: "Flor", in: container) {
        case .success:
            Issue.record("Read-only archive accepted a save")
        case .failure:
            break
        }
        let filed = try ModelContext(try ModelContainer(for: GradingSheet.self, configurations: ModelConfiguration(url: archive.fileURL)))
            .fetch(FetchDescriptor<GradingSheet>(predicate: #Predicate { $0.sheetCode == "RV-2507" }))
        #expect(filed.first?.grade == "Superior")
        ScratchFolder.discard(archive.fileURL)
    }

    @Test func twoConfigurationsWriteSeparateFiles() throws {
        let floor = PunchingFloor()
        let context = ModelContext(try floor.openFloor())
        context.insert(PunchRun(runCode: "RV-2603-A", operatorName: "Bruno Sá", stoppersPunched: 24_000, stopperSize: "45 × 24 mm"))
        context.insert(RejectSack(sackCode: "RJ-0309", kilos: 31.5, destination: "Granulate line"))
        try context.save()

        #expect(try ModelContext(floor.openShelf(floor.runsURL, for: PunchRun.self)).fetchCount(FetchDescriptor<PunchRun>()) == 1)
        #expect(try ModelContext(floor.openShelf(floor.rejectsURL, for: RejectSack.self)).fetchCount(FetchDescriptor<RejectSack>()) == 1)
        #expect(try ModelContext(floor.openShelf(floor.runsURL, for: PunchRun.self)).fetch(FetchDescriptor<PunchRun>()).first?.runCode == "RV-2603-A")
        #expect(try ModelContext(floor.openShelf(floor.rejectsURL, for: RejectSack.self)).fetch(FetchDescriptor<RejectSack>()).first?.sackCode == "RJ-0309")
        ScratchFolder.discard(floor.runsURL)
        ScratchFolder.discard(floor.rejectsURL)
    }

    @Test func configurationIsAValueUntilAContainerOpens() throws {
        let archiveURL = ScratchFolder.storeURL(named: "feira-print-archive")
        let archive = PrintRoomBooks.archiveBook(at: archiveURL)
        #expect(archive.allowsSave == false)
        #expect(archive.isStoredInMemoryOnly == false)
        #expect(!FileManager.default.fileExists(atPath: archiveURL.path))

        let tray = try ModelContainer(for: Schema([BrandProof.self]), configurations: [PrintRoomBooks.proofTray])
        let context = ModelContext(tray)
        context.insert(BrandProof(brandLine: "Quinta do Vale Escuro · 2022", inkColour: "Burnt umber", stopperLot: "RV-2603-A"))
        try context.save()
        #expect(try ModelContext(tray).fetchCount(FetchDescriptor<BrandProof>()) == 1)
        #expect(!FileManager.default.fileExists(atPath: archiveURL.path))
        ScratchFolder.discard(archiveURL)
    }

    @Test func sameMemoryNameStillOpensEmpty() throws {
        let readings = try PinhaoLine.runLine()
        #expect(readings == [
            StationReading(station: "Filler", passes: 1),
            StationReading(station: "Corker", passes: 0),
            StationReading(station: "Label table", passes: 0)
        ])
    }

    @Test func sendableContainerAcceptsActorSaves() async throws {
        let container = try MemoryStore.make(CellarPallet.self)
        let counted = try await ValeEscuroCellar.countBothAisles(into: container)
        #expect(counted == 225)
        let pallets = try ModelContext(container).fetch(FetchDescriptor<CellarPallet>(sortBy: [SortDescriptor(\.palletCode)]))
        #expect(pallets.map(\.palletCode) == ["VE-22-01", "VE-22-02", "VE-22-03", "VE-22-04"])
    }

    @Test func schemaVersionTravelsWithTheContainer() throws {
        let container = try GaiaRegister.open()
        #expect(container.schema.version == Schema.Version(2, 1, 0))
        let context = ModelContext(container)
        context.insert(LodgeEntry(lotCode: "VE-22", vintage: 2022, cases: 225, lodgeFloor: "Ground floor, north"))
        context.insert(LodgeEntry(lotCode: "SR-17", vintage: 2017, cases: 40, lodgeFloor: "Upper floor"))
        try context.save()
        let entries = try ModelContext(container).fetch(FetchDescriptor<LodgeEntry>())
        #expect(GaiaRegister.cases(ofVintage: 2022, in: entries) == 225)
    }

    @Test func deleteAllDataClearsTheTrialBook() throws {
        let book = try BlendTrialBook()
        try book.pour(GaiaTrials.firstTrial)
        #expect(book.sampleCodes == ["T1-A", "T1-B"])
        try book.clearTrial()
        #expect(book.sampleCodes.isEmpty)
        #expect(book.clearedWith == "delete(model:)")
        try book.pour(GaiaTrials.secondTrial)
        #expect(book.sampleCodes == ["T2-A"])
    }

    @Test func associatedConfigurationChoosesTheBook() throws {
        let shop = ScratchFolder.storeURL(named: "bonfim-shelves")
        let lodge = ScratchFolder.storeURL(named: "sarmento-price-list")
        let books = BonfimShop.books(shopFile: shop, lodgeFile: lodge)
        #expect(books[0].configuration.isStoredInMemoryOnly)
        #expect(books[1].configuration.url == shop)
        #expect(books[2].configuration.allowsSave == false)

        let counter = try ShelfBook.counterScratch.open()
        #expect(BonfimShop.describe(counter).contains("memory"))
        ScratchFolder.discard(shop)
        ScratchFolder.discard(lodge)
    }

    @Test func heldCardDoesNotRefreshAcrossContainers() throws {
        let file = BonfimStockFile(url: ScratchFolder.storeURL(named: "bonfim-stock"))
        let reading = try BonfimCounters.sellTwoBottles(in: file)
        #expect(reading.heldCard == 6)
        #expect(reading.newContext == 4)
        #expect(reading.countedBy == "Till, sale to Tasca da Graça")
        ScratchFolder.discard(file.url)
    }

    @Test func fileAndMemoryShelvesSplitOnReopen() throws {
        let folder = CorkFolder(ledgerURL: ScratchFolder.storeURL(named: "graca-cellar"))
        let summary = try folder.layOutMorning()
        #expect(summary.listings == ["Vale Escuro Vintage 2022 × 2, stoppers RV-2603-A"])
        #expect(summary.corkRows == [14])
        #expect(summary.pourNotes == 0)
        ScratchFolder.discard(folder.ledgerURL)
    }
}
