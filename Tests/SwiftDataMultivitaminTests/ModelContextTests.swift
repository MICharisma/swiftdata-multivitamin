import Foundation
import SwiftData
import Testing
@testable import SwiftDataMultivitamin

@MainActor
struct ModelContextTests {
    @Test func insertSetsHasChangesAndSaveClearsIt() throws {
        let context = try MemoryStore.context(for: CrackingTally.self)
        #expect(!context.hasChanges)
        context.insert(CrackingTally(
            crackerName: "Fadma Aït Brahim",
            kernelKilos: 9.5,
            crackedOn: GregorianDay.date(year: 2026, month: 10, day: 5, timeZoneIdentifier: "Africa/Casablanca")
        ))
        #expect(context.hasChanges)
        try context.save()
        #expect(!context.hasChanges)
        #expect(try context.freshCount(CrackingTally.self) == 1)
    }

    @Test func pendingArraysClearAfterSave() throws {
        let context = try MemoryStore.context(for: KernelSack.self)
        let yesterday = try TifawinRoll.fileYesterday(in: context)
        TifawinRoll.morningChanges(kept: yesterday.kept, torn: yesterday.torn, in: context)
        let pending = PendingRoll(context)
        #expect(pending.inserted == ["TF-0414", "TF-0415"])
        #expect(pending.changed == ["TF-0412"])
        #expect(pending.deleted == ["TF-0413"])
        try context.save()
        #expect(PendingRoll(context).isEmpty)
        #expect(try context.freshCount(KernelSack.self) == 3)
    }

    @Test func rollbackRestoresSavedPanMinutes() throws {
        let context = try MemoryStore.context(for: KernelRoast.self)
        let roast = KernelRoast(roastCode: "TF-0412-R", roasterName: "Khadija Oubella", panMinutes: 12, forCulinaryOil: true)
        context.insert(roast)
        try context.save()
        roast.panMinutes = 20
        #expect(context.hasChanges)
        context.rollback()
        #expect(roast.panMinutes == 12)
        #expect(!context.hasChanges)
        #expect(try context.freshFirst(KernelRoast.self)?.panMinutes == 12)
    }

    @Test func rollbackDropsAnUnsavedInsert() throws {
        let context = try MemoryStore.context(for: PanBatch.self)
        let batch = PanBatch(batchCode: "TF-0416-R", kernelKilos: 6, outcome: "Scorched")
        context.insert(batch)
        let reading = try context.discardUnsaved(batch)
        #expect(reading.contextCount == 0)
        #expect(reading.stillAttached == false)
        #expect(reading.hasChanges == false)
        #expect(reading.kilosOnTheCard == 6)
        #expect(try context.freshCount(PanBatch.self) == 0)
    }

    @Test func mainContextAutosavesByDefault() throws {
        let container = try ModelContainer(for: PressRun.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        #expect(container.mainContext.autosaveEnabled)
        #expect(ModelContext(container).autosaveEnabled == false)

        let manual = ModelContext(container)
        manual.autosaveEnabled = false
        manual.insert(PressRun(runCode: "AM-1009", pressOperator: "Youssef Bennani", roastedKilos: 22, oilLitres: 10))
        #expect(manual.hasChanges)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<PressRun>()) == 0)
        try manual.save()
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<PressRun>()) == 1)
    }

    @Test func throwingTransactionSavesNothing() throws {
        let context = try MemoryStore.context(for: OilDrum.self, PressCake.self)
        try AmazirPress.drainRun("AM-1009", litres: 10, cakeKilos: 12, in: context)
        #expect(try context.freshCount(OilDrum.self) == 1)
        #expect(try context.freshCount(PressCake.self) == 1)

        #expect(throws: DrumScaleJam.self) {
            try AmazirPress.drainOnJammedScale("AM-1010", in: context)
        }
        #expect(try context.freshCount(OilDrum.self) == 1)
        #expect(try context.freshCount(PressCake.self) == 1)
        #expect(!context.hasChanges)
    }

    @Test func deleteWaitsForSaveAndRollbackUndoesIt() throws {
        let context = try MemoryStore.context(for: RackBottle.self)
        try AmazirRack.bottle(into: context)
        let bottle = try #require(try context.fetch(FetchDescriptor<RackBottle>(predicate: #Predicate { $0.bottleCode == "AM-1009-02" })).first)
        context.delete(bottle)
        #expect(bottle.isDeleted)
        #expect(try context.freshCount(RackBottle.self) == 3)
        context.rollback()
        #expect(!bottle.isDeleted)
        #expect(try context.fetchCount(FetchDescriptor<RackBottle>()) == 3)
        context.delete(bottle)
        try context.save()
        #expect(try context.freshCount(RackBottle.self) == 2)
    }

    @Test func didSaveCarriesIdentifierArrays() throws {
        let context = try MemoryStore.context(for: CreamBatch.self)
        final class ReceiptBox: @unchecked Sendable {
            var receipts: [SaveReceipt] = []
        }
        let box = ReceiptBox()
        let token = NotificationCenter.default.addObserver(forName: ModelContext.didSave, object: context, queue: nil) { note in
            box.receipts.append(SaveReceipt(note))
        }
        defer { NotificationCenter.default.removeObserver(token) }

        try ZitounAtelier.morning(in: context)
        #expect(box.receipts.count == 3)
        #expect(box.receipts[0].inserted.count == 2)
        #expect(box.receipts[0].updated.isEmpty)
        #expect(box.receipts[0].deleted.isEmpty)
        #expect(box.receipts[1].updated.count == 1)
        #expect(box.receipts[2].deleted.count == 1)
        #expect(try context.freshCount(CreamBatch.self) == 1)
    }

    @Test func predicateDeleteWaitsForSave() throws {
        let context = try MemoryStore.context(for: ProductLabel.self)
        try ZitounLabels.printRun(in: context)
        #expect(try context.freshCount(ProductLabel.self) == 5)
        try ZitounLabels.purge(batch: "ZT-312", in: context)
        #expect(try context.fetchCount(FetchDescriptor<ProductLabel>()) == 3)
        #expect(try context.freshCount(ProductLabel.self) == 5)
        try context.save()
        #expect(try context.freshCount(ProductLabel.self) == 3)
    }

    @Test func enumerateEditsWaitForSave() throws {
        let context = try MemoryStore.context(for: SpiceJar.self)
        try RahbaShelf.stock(context)
        let slip = try RahbaShelf.raiseArganPrices(by: 10, in: context, batchSize: 2)
        #expect(slip.jarsWalked == 3)
        #expect(context.hasChanges)
        #expect(try context.freshFetch(FetchDescriptor<SpiceJar>(predicate: #Predicate { $0.jarName == "Amlou, 250 g" })).first?.priceDirhams == 60)
        try context.save()
        #expect(try context.freshFetch(FetchDescriptor<SpiceJar>(predicate: #Predicate { $0.jarName == "Amlou, 250 g" })).first?.priceDirhams == 70)
    }

    @Test func heldObjectStaysStaleAcrossContexts() throws {
        let counter = try MemoryStore.context(for: JarOrder.self)
        let orderID = try RahbaDesks.openMorningOrder(in: counter)
        let backDesk = ModelContext(counter.container)
        let reading = try RahbaDesks.sellTwoFromCounter(counter: counter, backDesk: backDesk, orderID: orderID)
        #expect(reading.counterJars == 2)
        #expect(reading.heldBackDesk == 4)
        #expect(reading.refetchBackDesk == 2)
    }

    @Test func modelForMaterializesAndRegisteredDoesNot() throws {
        let context = try MemoryStore.context(for: CourierSlip.self)
        let slip = CourierSlip(slipCode: "CK-18", destination: "Riad des Oliviers", bottles: 2)
        context.insert(slip)
        try context.save()
        let warehouse = ModelContext(context.container)
        let lookups = try MedinaCourier.lookUp(slip.persistentModelID, in: warehouse, afterDeletingIn: context)
        #expect(lookups.registeredBefore == false)
        #expect(lookups.modelForBottles == 2)
        #expect(lookups.registeredAfter == true)
        #expect(lookups.filedAfterVoid == 0)
    }

    @Test func actorSaveLeavesOnlyFiledCards() async throws {
        let context = try MemoryStore.context(for: ArganFolder.types)
        let sourceIDs = try ArganFolder.hang(in: context)
        let clerk = FolderClerk(modelContainer: context.container)
        let audit = try await clerk.closeMorning(sourceIDs)
        #expect(audit.filedHandover)
        #expect(audit.manifest.crackerName == "Fadma Aït Brahim")
        #expect(audit.manifest.pressRun == "AM-1009")
        #expect(audit.manifest.scorchedBatches == 0)
        #expect(try context.freshCount(PanBatch.self) == 0)
        #expect(try context.freshCount(CrackingTally.self) == 1)
        #expect(try context.freshCount(PressRun.self) == 1)
        #expect(try context.freshFirst(OilHandover.self)?.manifest.oilLitres == 10)
    }
}
