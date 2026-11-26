// Feature: ModelContainer and ModelConfiguration
// Slot 04 — Feira grading archive
// Teaches:
// - allowsSave: false opens an existing store file for reading.
// - A save through that container throws, and the file keeps last season's grades.

import Foundation
import SwiftData
import SwiftUI

@Model
final class GradingSheet {
    var sheetCode: String
    var graderName: String
    var grade: String
    var stopperCount: Int

    init(sheetCode: String, graderName: String, grade: String, stopperCount: Int) {
        self.sheetCode = sheetCode
        self.graderName = graderName
        self.grade = grade
        self.stopperCount = stopperCount
    }
}

struct GradingArchive {
    let fileURL: URL

    /// Last season's sheets, written once with an ordinary configuration.
    static func season2025() throws -> GradingArchive {
        let archive = GradingArchive(fileURL: ScratchFolder.storeURL(named: "feira-grading-2025"))
        let container = try ModelContainer(for: GradingSheet.self, configurations: ModelConfiguration(url: archive.fileURL))
        let context = ModelContext(container)
        context.insert(GradingSheet(sheetCode: "RV-2507", graderName: "Filipa Moura", grade: "Superior", stopperCount: 18_000))
        context.insert(GradingSheet(sheetCode: "RV-2508", graderName: "Filipa Moura", grade: "Extra", stopperCount: 6_500))
        try context.save()
        return archive
    }

    func openForReading() throws -> ModelContainer {
        try ModelContainer(
            for: GradingSheet.self,
            configurations: ModelConfiguration(url: fileURL, allowsSave: false)
        )
    }

    func regrade(_ sheetCode: String, to grade: String, in container: ModelContainer) -> Result<Void, any Error> {
        let context = ModelContext(container)
        return Result {
            let sheets = try context.fetch(FetchDescriptor<GradingSheet>(predicate: #Predicate { $0.sheetCode == sheetCode }))
            sheets.forEach { $0.grade = grade }
            try context.save()
        }
    }
}

struct GradingSheetScreen: View {
    @State private var opened = Result { () throws -> (GradingArchive, ModelContainer) in
        let archive = try GradingArchive.season2025()
        return (archive, try archive.openForReading())
    }

    var body: some View {
        switch opened {
        case .success(let (archive, container)):
            GradingArchiveDesk(archive: archive, container: container)
                .modelContainer(container)
        case .failure(let error):
            Text(error.localizedDescription).foregroundStyle(.red)
        }
    }
}

private struct GradingArchiveDesk: View {
    let archive: GradingArchive
    let container: ModelContainer
    @Query(sort: \GradingSheet.sheetCode) private var sheets: [GradingSheet]
    @State private var verdict: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 04",
            title: "Feira grading archive",
            situation: "On 2 March 2026 the Sorraia planks reach Rolhas Vasconcelos in Santa Maria da Feira. Before grading them, Filipa Moura opens last season's grading file to compare. The archive is for reading.",
            teaches: [
                "allowsSave: false opens an existing store file for reading.",
                "A save through that container throws, and the file keeps last season's grades."
            ]
        ) {
            Section("2025 sheets") {
                ForEach(sheets) { sheet in
                    LabeledContent(sheet.sheetCode, value: "\(sheet.grade) · \(sheet.stopperCount.formatted()) stoppers")
                }
                LabeledContent("allowsSave", value: String(container.configurations.allSatisfy(\.allowsSave)))
            }
            Section("Amend") {
                Button("Regrade RV-2507 as Flor") {
                    switch archive.regrade("RV-2507", to: "Flor", in: container) {
                    case .success:
                        verdict = "Saved"
                    case .failure(let error):
                        verdict = "Refused: \(error.localizedDescription)"
                    }
                }
                if let verdict {
                    Text(verdict).foregroundStyle(.secondary)
                }
            }
        }
    }
}
