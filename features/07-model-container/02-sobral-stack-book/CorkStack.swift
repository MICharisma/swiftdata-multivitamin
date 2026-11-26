// Feature: ModelContainer and ModelConfiguration
// Slot 02 — Sobral stack book
// Teaches:
// - ModelConfiguration(url:) puts the store in a file you choose.
// - A second container opened on that file reads what the first one saved.

import Foundation
import SwiftData
import SwiftUI

@propertyWrapper
struct StackBookFile {
    let wrappedValue: URL

    init(_ bookName: String) {
        wrappedValue = ScratchFolder.storeURL(named: bookName)
    }
}

@Model
final class CorkStack {
    var stackCode: String
    var plankCount: Int
    var yardCorner: String
    var stackedOn: Date

    init(stackCode: String, plankCount: Int, yardCorner: String, stackedOn: Date) {
        self.stackCode = stackCode
        self.plankCount = plankCount
        self.yardCorner = yardCorner
        self.stackedOn = stackedOn
    }
}

/// What the reopened book shows. The models stay with the container that read them.
struct StackLine: Hashable, Sendable {
    let stackCode: String
    let plankCount: Int
    let yardCorner: String
}

struct SobralStackBook {
    @StackBookFile("sobral-stacks") var fileURL: URL

    func open() throws -> ModelContainer {
        try ModelContainer(for: CorkStack.self, configurations: ModelConfiguration(url: fileURL))
    }

    func file(_ stack: CorkStack) throws {
        let container = try open()
        let context = ModelContext(container)
        context.insert(stack)
        try context.save()
    }

    func reopenedLines() throws -> [StackLine] {
        let container = try open()
        let stacks = try ModelContext(container).fetch(FetchDescriptor<CorkStack>(sortBy: [SortDescriptor(\.stackCode)]))
        return stacks.map { StackLine(stackCode: $0.stackCode, plankCount: $0.plankCount, yardCorner: $0.yardCorner) }
    }
}

struct CorkStackScreen: View {
    @State private var book = SobralStackBook()
    @State private var lines: [StackLine] = []
    @State private var filed = false
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 02",
            title: "Sobral stack book",
            situation: "On 18 July 2025 Manuel Cardoso stacks Joaquim's row-14 bark in the north corner of the Sobral yard. The planks rest there through the winter, so the stack book is a file, not a page in memory.",
            teaches: [
                "ModelConfiguration(url:) puts the store in a file you choose.",
                "A second container opened on that file reads what the first one saved."
            ]
        ) {
            Section("Book file") {
                Text(book.fileURL.lastPathComponent).monospaced()
                Text(ScratchFolder.sidecarNames(beside: book.fileURL).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Stacks") {
                Button("File stack P-14 and close the book") {
                    run {
                        try book.file(CorkStack(
                            stackCode: "P-14",
                            plankCount: 38,
                            yardCorner: "North corner",
                            stackedOn: GregorianDay.date(year: 2025, month: 7, day: 18, timeZoneIdentifier: "Europe/Lisbon")
                        ))
                        filed = true
                    }
                }
                .disabled(filed)
                Button("Reopen the book") {
                    run { lines = try book.reopenedLines() }
                }
                ForEach(lines, id: \.self) { line in
                    LabeledContent(line.stackCode, value: "\(line.plankCount) planks · \(line.yardCorner)")
                }
            }
            if let failure {
                Text(failure).foregroundStyle(.red)
            }
        }
    }

    private func run(_ step: () throws -> Void) {
        do { try step() } catch { failure = error.localizedDescription }
    }
}
