// Feature: ModelContext
// Slot 03 — Tifawin roast card
// Teaches:
// - Changing pan minutes marks the context changed.
// - rollback() clears hasChanges, but the open card keeps the new minutes; a fresh fetch still reads the filed value.

import SwiftData
import SwiftUI

@Model
final class KernelRoast {
    var roastCode: String
    var roasterName: String
    var panMinutes: Int
    var forCulinaryOil: Bool

    init(roastCode: String, roasterName: String, panMinutes: Int, forCulinaryOil: Bool) {
        self.roastCode = roastCode
        self.roasterName = roasterName
        self.panMinutes = panMinutes
        self.forCulinaryOil = forCulinaryOil
    }
}

struct KernelRoastScreen: View {
    var body: some View {
        RoastCardDesk().inMemoryStore(for: KernelRoast.self)
    }
}

private struct RoastCardDesk: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var roasts: [KernelRoast]
    @State private var filedMinutes = "—"

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 03",
            title: "Tifawin roast card",
            situation: "On 7 October 2026 Khadija Oubella roasts sack TF-0412 in the clay pan for culinary oil: twelve minutes. A helper nudges the card to twenty before Khadija sees it.",
            teaches: [
                "Changing pan minutes marks the context changed.",
                "rollback() clears hasChanges, but the open card keeps the new minutes; a fresh fetch still reads the filed value."
            ]
        ) {
            if let roast = roasts.first {
                RoastFields(roast: roast)
                Section {
                    LabeledContent("On the card", value: "\(roast.panMinutes) minutes")
                    LabeledContent("hasChanges", value: String(modelContext.hasChanges))
                    LabeledContent("Filed minutes", value: filedMinutes)
                    Button("Roll back the context", role: .destructive) {
                        modelContext.rollback()
                        refreshFiled()
                    }
                    Button("Keep the new minutes") {
                        try? modelContext.save()
                        refreshFiled()
                    }
                }
            } else {
                Button("File Khadija's roast") {
                    modelContext.insert(KernelRoast(roastCode: "TF-0412-R", roasterName: "Khadija Oubella", panMinutes: 12, forCulinaryOil: true))
                    try? modelContext.save()
                    refreshFiled()
                }
            }
        }
    }

    private func refreshFiled() {
        filedMinutes = (try? modelContext.freshFirst(KernelRoast.self)).map { "\($0.panMinutes)" } ?? "—"
    }
}

private struct RoastFields: View {
    @Bindable var roast: KernelRoast

    var body: some View {
        Section(roast.roastCode) {
            LabeledContent("Roaster", value: roast.roasterName)
            Stepper("Pan minutes: \(roast.panMinutes)", value: $roast.panMinutes, in: 0...30)
            Toggle("For culinary oil", isOn: $roast.forCulinaryOil)
        }
    }
}
