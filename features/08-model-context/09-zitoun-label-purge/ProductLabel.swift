// Feature: ModelContext
// Slot 09 — Zitoun label purge
// Teaches:
// - delete(model:where:) removes every label that matches a predicate, without fetching them first.
// - The purge waits for save before the store loses the matching labels.

import SwiftData
import SwiftUI

@Model
final class ProductLabel {
    var labelNumber: Int
    var batchCode: String
    var language: String

    init(labelNumber: Int, batchCode: String, language: String) {
        self.labelNumber = labelNumber
        self.batchCode = batchCode
        self.language = language
    }
}

enum ZitounLabels {
    static func printRun(in context: ModelContext) throws {
        let sheet: [(batch: String, languages: [String])] = [
            ("ZT-311", ["Français", "العربية", "English"]),
            ("ZT-312", ["Français", "العربية"])
        ]
        var number = 1
        for (batch, languages) in sheet {
            for language in languages {
                context.insert(ProductLabel(labelNumber: number, batchCode: batch, language: language))
                number += 1
            }
        }
        try context.save()
    }

    static func purge(batch pulledBatch: String, in context: ModelContext) throws {
        try context.delete(model: ProductLabel.self, where: #Predicate { $0.batchCode == pulledBatch })
    }
}

struct ProductLabelScreen: View {
    var body: some View {
        LabelPurgeDesk().inMemoryStore(for: ProductLabel.self)
    }
}

private struct LabelPurgeDesk: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProductLabel.labelNumber) private var labels: [ProductLabel]
    @State private var filed: [String] = []

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 09",
            title: "Zitoun label purge",
            situation: "On 14 October 2026 Salma's print run holds labels for the night cream and the pulled black soap, in French, Arabic, and English. The soap labels have to go before the courier to Rahba Kedima.",
            teaches: [
                "delete(model:where:) removes every label that matches a predicate, without fetching them first.",
                "The purge waits for save before the store loses the matching labels."
            ]
        ) {
            Section("Labels in the context") {
                ForEach(labels) { label in
                    LabeledContent("No. \(label.labelNumber) · \(label.batchCode)", value: label.language)
                }
            }
            Section("Filed in the store") {
                Text(filed.isEmpty ? "Not read yet" : filed.joined(separator: ", "))
            }
            Section {
                Button("Print the labels") { act { try ZitounLabels.printRun(in: modelContext) } }
                    .disabled(!labels.isEmpty)
                Button("Purge the ZT-312 labels") { act { try ZitounLabels.purge(batch: "ZT-312", in: modelContext) } }
                Button("Save") { act { try modelContext.save() } }
            }
        }
    }

    private func act(_ step: () throws -> Void) {
        try? step()
        filed = ((try? modelContext.freshFetch(FetchDescriptor<ProductLabel>(sortBy: [SortDescriptor(\.labelNumber)]))) ?? [])
            .map { "\($0.labelNumber) \($0.batchCode)" }
    }
}
