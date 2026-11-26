import Foundation
import SwiftData
import Testing
@testable import SwiftDataMultivitamin

@Model final class ProbeCorkBale {
    var baleCode: String
    var kilos: Int
    init(baleCode: String, kilos: Int) { self.baleCode = baleCode; self.kilos = kilos }
}

@Model final class ProbeRejectSack {
    var sackCode: String
    init(sackCode: String) { self.sackCode = sackCode }
}

@Model final class ProbeBoilingBatch {
    var batchCode: String
    @Relationship(deleteRule: .cascade) var planks: [ProbePlank] = []
    init(batchCode: String) { self.batchCode = batchCode }
}

@Model final class ProbePlank {
    var plankCode: String
    var batch: ProbeBoilingBatch?
    init(plankCode: String) { self.plankCode = plankCode }
}

private func probe(_ label: String, _ value: @autoclosure () throws -> Any) {
    do { print("PROBE \(label): \(try value())") } catch { print("PROBE \(label): THREW \(type(of: error)) \(error)") }
}

private func scratchURL(_ name: String) -> URL {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent("probe-\(UUID().uuidString)", isDirectory: true)
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    return folder.appendingPathComponent("\(name).store")
}

@MainActor
@Suite(.serialized)
struct ContainerContextProbe {
    @Test func p01ReadOnly() throws {
        let url = scratchURL("grading")
        do {
            let writer = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: url))
            let ctx = ModelContext(writer)
            ctx.insert(ProbeCorkBale(baleCode: "CB-1", kilos: 40))
            try ctx.save()
        }
        do {
            let reader = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: url, allowsSave: false))
            let ctx = ModelContext(reader)
            probe("p01 readOnly count", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
            probe("p01 readOnly config allowsSave", reader.configurations.first!.allowsSave)
            let bale = try ctx.fetch(FetchDescriptor<ProbeCorkBale>()).first!
            bale.kilos = 41
            probe("p01 edit hasChanges", ctx.hasChanges)
            ctx.insert(ProbeCorkBale(baleCode: "CB-2", kilos: 30))
            probe("p01 save", try { try ctx.save(); return "saved" }())
            probe("p01 after save hasChanges", ctx.hasChanges)
            probe("p01 fresh count", try ModelContext(reader).fetchCount(FetchDescriptor<ProbeCorkBale>()))
            probe("p01 fresh kilos", try ModelContext(reader).fetch(FetchDescriptor<ProbeCorkBale>()).map(\.kilos))
            probe("p01 main autosave", reader.mainContext.autosaveEnabled)
        }
        do {
            let again = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: url))
            probe("p01 reopen rw count", try ModelContext(again).fetch(FetchDescriptor<ProbeCorkBale>()).map { "\($0.baleCode)=\($0.kilos)" })
        }
        do {
            let memory = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: false))
            let ctx = ModelContext(memory)
            ctx.insert(ProbeCorkBale(baleCode: "CB-3", kilos: 1))
            probe("p01b memory readonly save", try { try ctx.save(); return "saved" }())
            probe("p01b fresh count", try ModelContext(memory).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        } catch { print("PROBE p01b open THREW \(error)") }
    }

    @Test func p02ConfigurationValues() {
        let plain = ModelConfiguration()
        probe("p02 default name", plain.name)
        probe("p02 default url", plain.url.path)
        probe("p02 default inMemory", plain.isStoredInMemoryOnly)
        probe("p02 default allowsSave", plain.allowsSave)
        probe("p02 default schema", String(describing: plain.schema))
        probe("p02 default cloudKit id", String(describing: plain.cloudKitContainerIdentifier))
        probe("p02 default group id", String(describing: plain.groupAppContainerIdentifier))
        let memory = ModelConfiguration(isStoredInMemoryOnly: true)
        probe("p02 memory name", memory.name)
        probe("p02 memory url", memory.url.path)
        let named = ModelConfiguration("feira-print")
        probe("p02 named url", named.url.path)
        let namedMemory = ModelConfiguration("feira-print", isStoredInMemoryOnly: true)
        probe("p02 named memory url", namedMemory.url.path)
        let typed = ModelConfiguration(for: ProbeCorkBale.self, isStoredInMemoryOnly: true)
        probe("p02 typed schema entities", typed.schema?.entities.map(\.name) ?? [])
        probe("p02 typed name", typed.name)
        let kit = ModelConfiguration("cellar", cloudKitDatabase: .private("iCloud.pt.feira.rolhas"))
        probe("p02 ck id", String(describing: kit.cloudKitContainerIdentifier))
        let group = ModelConfiguration("cellar", groupContainer: .identifier("group.pt.feira.rolhas"))
        probe("p02 group id", String(describing: group.groupAppContainerIdentifier))
        probe("p02 equal same name", ModelConfiguration("a", isStoredInMemoryOnly: true) == ModelConfiguration("a", isStoredInMemoryOnly: true))
        probe("p02 equal different allowsSave", ModelConfiguration("a", isStoredInMemoryOnly: true) == ModelConfiguration("a", isStoredInMemoryOnly: true, allowsSave: false))
        probe("p02 equal different name", ModelConfiguration("a", isStoredInMemoryOnly: true) == ModelConfiguration("b", isStoredInMemoryOnly: true))
        let u = scratchURL("same")
        probe("p02 equal same url diff names", ModelConfiguration("a", url: u) == ModelConfiguration("b", url: u))
        probe("p02 url config name", ModelConfiguration(url: u).name)
        probe("p02 set count dup", Set([ModelConfiguration("a", isStoredInMemoryOnly: true), ModelConfiguration("a", isStoredInMemoryOnly: true)]).count)
    }

    @Test func p03SharedMemoryNames() throws {
        let first = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration("pinhao-line", isStoredInMemoryOnly: true))
        let ctx = ModelContext(first)
        ctx.insert(ProbeCorkBale(baleCode: "PL-1", kilos: 2))
        try ctx.save()
        let second = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration("pinhao-line", isStoredInMemoryOnly: true))
        probe("p03 same name second count", try ModelContext(second).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let third = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration("pinhao-other", isStoredInMemoryOnly: true))
        probe("p03 other name count", try ModelContext(third).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let d1 = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let dctx = ModelContext(d1)
        dctx.insert(ProbeCorkBale(baleCode: "PL-2", kilos: 2))
        try dctx.save()
        let d2 = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        probe("p03 default memory second count", try ModelContext(d2).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p03 first mainContext identical", first.mainContext === first.mainContext)
        probe("p03 main autosave", first.mainContext.autosaveEnabled)
        probe("p03 new ctx autosave", ModelContext(first).autosaveEnabled)
    }

    @Test func p04TwoConfigurations() throws {
        let baleURL = scratchURL("bales")
        let rejectURL = scratchURL("rejects")
        do {
            let both = try ModelContainer(
                for: Schema([ProbeCorkBale.self, ProbeRejectSack.self]),
                configurations: [
                    ModelConfiguration("bales", schema: Schema([ProbeCorkBale.self]), url: baleURL),
                    ModelConfiguration("rejects", schema: Schema([ProbeRejectSack.self]), url: rejectURL)
                ]
            )
            probe("p04 configurations", both.configurations.map(\.name).sorted())
            let ctx = ModelContext(both)
            ctx.insert(ProbeCorkBale(baleCode: "B-1", kilos: 5))
            ctx.insert(ProbeRejectSack(sackCode: "R-1"))
            try ctx.save()
            probe("p04 both counts", "\(try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>())) \(try ctx.fetchCount(FetchDescriptor<ProbeRejectSack>()))")
        }
        probe("p04 files", (try? FileManager.default.contentsOfDirectory(atPath: baleURL.deletingLastPathComponent().path)) ?? [])
        do {
            let balesOnly = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: baleURL))
            probe("p04 bales file bale count", try ModelContext(balesOnly).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        } catch { print("PROBE p04 bales reopen THREW \(error)") }
        do {
            let rejectsOnly = try ModelContainer(for: ProbeRejectSack.self, configurations: ModelConfiguration(url: rejectURL))
            probe("p04 rejects file reject count", try ModelContext(rejectsOnly).fetchCount(FetchDescriptor<ProbeRejectSack>()))
        } catch { print("PROBE p04 rejects reopen THREW \(error)") }
        do {
            let wrong = try ModelContainer(for: ProbeRejectSack.self, configurations: ModelConfiguration(url: baleURL))
            probe("p04 bales file reject count", try ModelContext(wrong).fetchCount(FetchDescriptor<ProbeRejectSack>()))
        } catch { print("PROBE p04 wrong reopen THREW \(error)") }
        // a type in container schema but not in any configuration schema
        do {
            let partial = try ModelContainer(
                for: Schema([ProbeCorkBale.self, ProbeRejectSack.self]),
                configurations: [ModelConfiguration("only-bales", schema: Schema([ProbeCorkBale.self]), isStoredInMemoryOnly: true)]
            )
            let ctx = ModelContext(partial)
            ctx.insert(ProbeRejectSack(sackCode: "R-2"))
            probe("p04 orphan save", try { try ctx.save(); return "saved" }())
            probe("p04 orphan count", try ModelContext(partial).fetchCount(FetchDescriptor<ProbeRejectSack>()))
        } catch { print("PROBE p04 partial open THREW \(error)") }
        // two memory configurations, both covering one type
        do {
            let doubled = try ModelContainer(
                for: Schema([ProbeCorkBale.self]),
                configurations: [ModelConfiguration("left", isStoredInMemoryOnly: true), ModelConfiguration("right", isStoredInMemoryOnly: true)]
            )
            let ctx = ModelContext(doubled)
            ctx.insert(ProbeCorkBale(baleCode: "D-1", kilos: 1))
            try ctx.save()
            probe("p04 doubled count", try ModelContext(doubled).fetchCount(FetchDescriptor<ProbeCorkBale>()))
            probe("p04 doubled configs", doubled.configurations.count)
        } catch { print("PROBE p04 doubled THREW \(error)") }
    }

    @Test func p05SchemaVersionAndRelated() throws {
        let schema = Schema([ProbeCorkBale.self], version: Schema.Version(2, 1, 0))
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
        probe("p05 version", container.schema.version)
        probe("p05 config schema version", String(describing: container.configurations.first?.schema?.version))
        let related = try ModelContainer(for: ProbeBoilingBatch.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        probe("p05 related entities", related.schema.entities.map(\.name).sorted())
        let child = try ModelContainer(for: ProbePlank.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        probe("p05 child entities", child.schema.entities.map(\.name).sorted())
        probe("p05 default schema version", Schema([ProbeCorkBale.self]).version)
    }

    @Test func p06ContextInsertRollback() throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)
        let bale = ProbeCorkBale(baleCode: "T-1", kilos: 12)
        probe("p06 before insert modelContext nil", bale.modelContext == nil)
        probe("p06 before insert hasChanges", ctx.hasChanges)
        ctx.insert(bale)
        probe("p06 after insert hasChanges", ctx.hasChanges)
        probe("p06 inserted array", ctx.insertedModelsArray.count)
        probe("p06 fetch before save sees insert", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p06 id temporary storeIdentifier", String(describing: bale.persistentModelID.storeIdentifier))
        let tempID = bale.persistentModelID
        ctx.rollback()
        probe("p06 after rollback hasChanges", ctx.hasChanges)
        probe("p06 after rollback modelContext nil", bale.modelContext == nil)
        probe("p06 after rollback isDeleted", bale.isDeleted)
        probe("p06 after rollback count", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p06 after rollback kilos", bale.kilos)
        probe("p06 after rollback inserted", ctx.insertedModelsArray.count)
        ctx.insert(bale)
        probe("p06 reinsert hasChanges", ctx.hasChanges)
        try ctx.save()
        probe("p06 reinsert saved fresh count", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p06 id changed after save", tempID != bale.persistentModelID)
        probe("p06 saved storeIdentifier", String(describing: bale.persistentModelID.storeIdentifier))
        bale.kilos = 20
        probe("p06 changed array", ctx.changedModelsArray.count)
        probe("p06 edit hasChanges", ctx.hasChanges)
        ctx.rollback()
        probe("p06 edit rolled back kilos", bale.kilos)
        bale.kilos = 12
        probe("p06 set same value hasChanges", ctx.hasChanges)
        ctx.delete(bale)
        probe("p06 deleted array", ctx.deletedModelsArray.count)
        probe("p06 delete isDeleted", bale.isDeleted)
        probe("p06 fetch after delete unsaved", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        ctx.rollback()
        probe("p06 delete rolled back isDeleted", bale.isDeleted)
        probe("p06 delete rolled back count", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p06 save with no changes", try { try ctx.save(); return "saved" }())
        ctx.insert(bale)
        probe("p06 insert already-saved hasChanges", ctx.hasChanges)
    }

    @Test func p07Transaction() throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)
        try ctx.transaction {
            ctx.insert(ProbeCorkBale(baleCode: "TX-1", kilos: 1))
            ctx.insert(ProbeCorkBale(baleCode: "TX-2", kilos: 2))
            probe("p07 inside hasChanges", ctx.hasChanges)
        }
        probe("p07 after hasChanges", ctx.hasChanges)
        probe("p07 fresh count", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        struct PressJam: Error {}
        do {
            try ctx.transaction {
                ctx.insert(ProbeCorkBale(baleCode: "TX-3", kilos: 3))
                throw PressJam()
            }
        } catch { print("PROBE p07 throw caught \(error)") }
        probe("p07 after throw hasChanges", ctx.hasChanges)
        probe("p07 after throw fresh count", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p07 after throw ctx count", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let main = container.mainContext
        try main.transaction {
            main.insert(ProbeCorkBale(baleCode: "TX-4", kilos: 4))
        }
        probe("p07 main tx fresh count", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
    }

    @Test func p08Notifications() async throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)
        var seen: [String] = []
        let token = NotificationCenter.default.addObserver(forName: ModelContext.didSave, object: ctx, queue: nil) { note in
            let info = note.userInfo ?? [:]
            print("PROBE p08 didSave keys \(info.keys.map { "\($0)" }.sorted())")
            for (key, value) in info { print("PROBE p08 \(key) -> \(type(of: value)) \(value)") }
            print("PROBE p08 object type \(String(describing: note.object.map { type(of: $0) }))")
        }
        let willToken = NotificationCenter.default.addObserver(forName: ModelContext.willSave, object: ctx, queue: nil) { note in
            print("PROBE p08 willSave userInfo \(String(describing: note.userInfo))")
        }
        let bale = ProbeCorkBale(baleCode: "N-1", kilos: 1)
        ctx.insert(bale)
        try ctx.save()
        seen.append("first")
        bale.kilos = 2
        try ctx.save()
        print("PROBE p08 empty save next")
        try ctx.save()
        ctx.delete(bale)
        try ctx.save()
        NotificationCenter.default.removeObserver(token)
        NotificationCenter.default.removeObserver(willToken)
        probe("p08 keys", "\(ModelContext.NotificationKey.insertedIdentifiers.rawValue) \(ModelContext.NotificationKey.updatedIdentifiers.rawValue) \(ModelContext.NotificationKey.deletedIdentifiers.rawValue)")
        let other = ModelContext(container)
        let otherToken = NotificationCenter.default.addObserver(forName: ModelContext.didSave, object: nil, queue: nil) { note in
            print("PROBE p08 nil-object observer fired \(note.userInfo?.count ?? -1)")
        }
        other.insert(ProbeCorkBale(baleCode: "N-2", kilos: 3))
        try other.save()
        NotificationCenter.default.removeObserver(otherToken)
        _ = seen
    }

    @Test func p09BatchDelete() throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)
        let light = ProbeCorkBale(baleCode: "L-1", kilos: 3)
        ctx.insert(light)
        ctx.insert(ProbeCorkBale(baleCode: "H-1", kilos: 30))
        ctx.insert(ProbeCorkBale(baleCode: "L-2", kilos: 4))
        try ctx.save()
        let floor = 10
        try ctx.delete(model: ProbeCorkBale.self, where: #Predicate { $0.kilos < floor })
        probe("p09 hasChanges after batch", ctx.hasChanges)
        probe("p09 ctx count after batch", try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p09 fresh count before save", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p09 light isDeleted", light.isDeleted)
        probe("p09 deleted array", ctx.deletedModelsArray.count)
        try ctx.save()
        probe("p09 fresh count after save", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        // unsaved insert matching the predicate
        let unsaved = ProbeCorkBale(baleCode: "L-3", kilos: 1)
        ctx.insert(unsaved)
        try ctx.delete(model: ProbeCorkBale.self, where: #Predicate { $0.kilos < floor })
        probe("p09 unsaved matching isDeleted", unsaved.isDeleted)
        try ctx.save()
        probe("p09 fresh after unsaved batch", try ModelContext(container).fetch(FetchDescriptor<ProbeCorkBale>()).map(\.baleCode))
        // rollback after batch
        ctx.insert(ProbeCorkBale(baleCode: "L-4", kilos: 2))
        try ctx.save()
        try ctx.delete(model: ProbeCorkBale.self, where: #Predicate { $0.kilos < floor })
        ctx.rollback()
        probe("p09 after rollback fresh", try ModelContext(container).fetch(FetchDescriptor<ProbeCorkBale>()).map(\.baleCode).sorted())
        probe("p09 after rollback ctx", try ctx.fetch(FetchDescriptor<ProbeCorkBale>()).map(\.baleCode).sorted())
    }

    @Test func p10Enumerate() throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)
        for n in 1...7 { ctx.insert(ProbeCorkBale(baleCode: "E-\(n)", kilos: n)) }
        try ctx.save()
        var seen = 0
        try ctx.enumerate(FetchDescriptor<ProbeCorkBale>(sortBy: [SortDescriptor(\.kilos)]), batchSize: 3) { bale in
            seen += 1
            bale.kilos += 100
        }
        probe("p10 seen", seen)
        probe("p10 hasChanges after enumerate", ctx.hasChanges)
        try ctx.save()
        probe("p10 fresh kilos", try ModelContext(container).fetch(FetchDescriptor<ProbeCorkBale>(sortBy: [SortDescriptor(\.kilos)])).map(\.kilos))
        var unsavedSeen = 0
        ctx.insert(ProbeCorkBale(baleCode: "E-8", kilos: 8))
        probe("p10 enumerate with unsaved", try { try ctx.enumerate(FetchDescriptor<ProbeCorkBale>()) { _ in unsavedSeen += 1 }; return unsavedSeen }())
        var escaping: [ProbeCorkBale] = []
        probe("p10 enumerate allowEscaping", try { try ctx.enumerate(FetchDescriptor<ProbeCorkBale>(), batchSize: 2, allowEscapingMutations: true) { escaping.append($0) }; return escaping.count }())
    }

    @Test func p11TwoContexts() throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let kitchen = ModelContext(container)
        let bale = ProbeCorkBale(baleCode: "F-1", kilos: 10)
        kitchen.insert(bale)
        try kitchen.save()
        let shop = ModelContext(container)
        let shopBale = try shop.fetch(FetchDescriptor<ProbeCorkBale>()).first!
        bale.kilos = 11
        probe("p11 shop sees unsaved", shopBale.kilos)
        try kitchen.save()
        probe("p11 shop held object after other save", shopBale.kilos)
        probe("p11 shop refetch", try shop.fetch(FetchDescriptor<ProbeCorkBale>()).first!.kilos)
        shopBale.kilos = 15
        bale.kilos = 13
        try kitchen.save()
        probe("p11 shop save over", try { try shop.save(); return "saved" }())
        probe("p11 fresh after both", try ModelContext(container).fetch(FetchDescriptor<ProbeCorkBale>()).first!.kilos)
        probe("p11 kitchen object after shop save", bale.kilos)
        probe("p11 kitchen refetch", try kitchen.fetch(FetchDescriptor<ProbeCorkBale>()).first!.kilos)
        let id = bale.persistentModelID
        let desk = ModelContext(container)
        probe("p11 registered before", String(describing: desk.registeredModel(for: id) as ProbeCorkBale?))
        let modelFor = desk.model(for: id) as? ProbeCorkBale
        probe("p11 model(for:) kilos", String(describing: modelFor?.kilos))
        probe("p11 registered after", (desk.registeredModel(for: id) as ProbeCorkBale?) === modelFor)
        let ghostContext = ModelContext(container)
        let unsaved = ProbeCorkBale(baleCode: "F-2", kilos: 1)
        kitchen.insert(unsaved)
        let tempID = unsaved.persistentModelID
        probe("p11 model(for: temp) in other", String(describing: (ghostContext.model(for: tempID) as? ProbeCorkBale)?.kilos))
        probe("p11 registered temp in own", (kitchen.registeredModel(for: tempID) as ProbeCorkBale?) === unsaved)
        kitchen.delete(unsaved)
        try kitchen.save()
        kitchen.delete(bale)
        try kitchen.save()
        let gone = ModelContext(container)
        let ghost = gone.model(for: id)
        probe("p11 model(for: deleted) type", "\(type(of: ghost))")
        probe("p11 model(for: deleted) isDeleted", ghost.isDeleted)
    }

    @Test func p12Autosave() async throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let main = container.mainContext
        probe("p12 main autosave", main.autosaveEnabled)
        main.insert(ProbeCorkBale(baleCode: "A-1", kilos: 1))
        var waited = 0
        while waited < 40 {
            if (try? ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>())) == 1 { break }
            try await Task.sleep(for: .milliseconds(100))
            waited += 1
        }
        probe("p12 main autosave after ms", waited * 100)
        probe("p12 main hasChanges", main.hasChanges)
        let other = ModelContext(container)
        other.autosaveEnabled = true
        other.insert(ProbeCorkBale(baleCode: "A-2", kilos: 2))
        waited = 0
        while waited < 40 {
            if (try? ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>())) == 2 { break }
            try await Task.sleep(for: .milliseconds(100))
            waited += 1
        }
        probe("p12 other autosave after ms", waited * 100)
        let off = container.mainContext
        off.autosaveEnabled = false
        off.insert(ProbeCorkBale(baleCode: "A-3", kilos: 3))
        try await Task.sleep(for: .seconds(2))
        probe("p12 off count after 2s", try ModelContext(container).fetchCount(FetchDescriptor<ProbeCorkBale>()))
    }

    @Test func p13DeleteAllAndTwoContainersOneFile() throws {
        let url = scratchURL("gaia")
        let first = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: url))
        let second = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(url: url))
        let a = ModelContext(first)
        a.insert(ProbeCorkBale(baleCode: "G-1", kilos: 1))
        try a.save()
        probe("p13 second sees first save", try ModelContext(second).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let held = try ModelContext(second).fetch(FetchDescriptor<ProbeCorkBale>()).first
        let bctx = ModelContext(second)
        let bBale = try bctx.fetch(FetchDescriptor<ProbeCorkBale>()).first!
        let aBale = try a.fetch(FetchDescriptor<ProbeCorkBale>()).first!
        aBale.kilos = 9
        try a.save()
        probe("p13 b held after a edit", bBale.kilos)
        probe("p13 b refetch after a edit", try bctx.fetch(FetchDescriptor<ProbeCorkBale>()).first!.kilos)
        probe("p13 b fresh after a edit", try ModelContext(second).fetch(FetchDescriptor<ProbeCorkBale>()).first!.kilos)
        _ = held
        guard #available(macOS 15, *) else { return }
        first.deleteAllData()
        probe("p13 file deleteAll count", try ModelContext(first).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p13 file exists after deleteAll", FileManager.default.fileExists(atPath: url.path))
        probe("p13 second after deleteAll", try ModelContext(second).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let memory = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let m = ModelContext(memory)
        m.insert(ProbeCorkBale(baleCode: "G-2", kilos: 1))
        try m.save()
        memory.deleteAllData()
        probe("p13 deleteAllData memory count", try ModelContext(memory).fetchCount(FetchDescriptor<ProbeCorkBale>()))
        probe("p13 deleteAllData old ctx count", try m.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        m.insert(ProbeCorkBale(baleCode: "G-3", kilos: 1))
        probe("p13 save after deleteAll", try { try m.save(); return "saved" }())
        probe("p13 count after deleteAll + insert", try ModelContext(memory).fetchCount(FetchDescriptor<ProbeCorkBale>()))
    }

    @Test func p14ContainerSendableAndProcessPending() async throws {
        let container = try ModelContainer(for: ProbeCorkBale.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let count = try await Task.detached {
            let ctx = ModelContext(container)
            ctx.insert(ProbeCorkBale(baleCode: "S-1", kilos: 1))
            try ctx.save()
            return try ctx.fetchCount(FetchDescriptor<ProbeCorkBale>())
        }.value
        probe("p14 detached count", count)
        probe("p14 main sees", try container.mainContext.fetchCount(FetchDescriptor<ProbeCorkBale>()))
        let ctx = ModelContext(container)
        ctx.insert(ProbeCorkBale(baleCode: "S-2", kilos: 2))
        ctx.processPendingChanges()
        probe("p14 hasChanges after processPending", ctx.hasChanges)
        probe("p14 ctx.container same", ctx.container === container)
        probe("p14 undoManager default", String(describing: ctx.undoManager))
        probe("p14 main undoManager default", String(describing: container.mainContext.undoManager))
    }
}
