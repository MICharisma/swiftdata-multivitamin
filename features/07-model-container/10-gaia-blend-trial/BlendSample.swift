// Feature: ModelContainer and ModelConfiguration
// Slot 10 — Gaia blend trial
// Teaches:
// - delete(model:) with no predicate removes every sample in the trial book.
// - The same container takes the afternoon trial without being reopened.

import Observation
import SwiftData
import SwiftUI

@Model
final class BlendSample {
    var sampleCode: String
    var pipeNumber: Int
    var tasterNote: String

    init(sampleCode: String, pipeNumber: Int, tasterNote: String) {
        self.sampleCode = sampleCode
        self.pipeNumber = pipeNumber
        self.tasterNote = tasterNote
    }
}

@MainActor
@Observable
final class BlendTrialBook {
    let container: ModelContainer
    private(set) var sampleCodes: [String] = []
    private(set) var clearedWith = ""

    init() throws {
        container = try ModelContainer(for: BlendSample.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    func pour(_ samples: [BlendSample]) throws {
        let context = container.mainContext
        samples.forEach(context.insert)
        try context.save()
        try reread()
    }

    func clearTrial() throws {
        try container.mainContext.delete(model: BlendSample.self)
        try container.mainContext.save()
        clearedWith = "delete(model:)"
        try reread()
    }

    private func reread() throws {
        sampleCodes = try ModelContext(container)
            .fetch(FetchDescriptor<BlendSample>(sortBy: [SortDescriptor(\.sampleCode)]))
            .map(\.sampleCode)
    }
}

enum GaiaTrials {
    static var firstTrial: [BlendSample] {
        [
            BlendSample(sampleCode: "T1-A", pipeNumber: 112, tasterNote: "VE-22 with 10% of pipe 112"),
            BlendSample(sampleCode: "T1-B", pipeNumber: 118, tasterNote: "VE-22 with 15% of pipe 118")
        ]
    }

    static var secondTrial: [BlendSample] {
        [BlendSample(sampleCode: "T2-A", pipeNumber: 118, tasterNote: "VE-22 with 12% of pipe 118")]
    }
}

struct BlendSampleScreen: View {
    @State private var book = Result { try BlendTrialBook() }

    var body: some View {
        switch book {
        case .success(let book):
            BlendTrialDesk(book: book)
        case .failure(let error):
            Text(error.localizedDescription).foregroundStyle(.red)
        }
    }
}

private struct BlendTrialDesk: View {
    let book: BlendTrialBook
    @State private var failure: String?

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContainer · 10",
            title: "Gaia blend trial",
            situation: "On 27 April 2026 Helena Sarmento tries VE-22 against two older pipes. The trial samples are poured away at the end of the morning, and the afternoon trial starts on a clean book.",
            teaches: [
                "delete(model:) with no predicate removes every sample in the trial book.",
                "The same container takes the afternoon trial without being reopened."
            ]
        ) {
            Section("Samples in the store") {
                Text(book.sampleCodes.isEmpty ? "None" : book.sampleCodes.joined(separator: ", "))
                if !book.clearedWith.isEmpty {
                    LabeledContent("Cleared with", value: book.clearedWith)
                }
            }
            Section("Trial") {
                Button("Pour the morning trial") { act { try book.pour(GaiaTrials.firstTrial) } }
                Button("Pour away the morning trial") { act { try book.clearTrial() } }
                Button("Pour the afternoon trial") { act { try book.pour(GaiaTrials.secondTrial) } }
            }
            if let failure { Text(failure).foregroundStyle(.red) }
        }
    }

    private func act(_ step: () throws -> Void) {
        do { try step() } catch { failure = error.localizedDescription }
    }
}
