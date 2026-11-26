// Feature: ModelContext
// Slot 03 — Tifawin roast card
// Teaches:
// - An edit to a saved card waits in the context until the next save.
// - rollback() puts the card back to its saved values.

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

    var body: some View {
        ScenarioChrome(
            kicker: "ModelContext · 03",
            title: "Tifawin roast card",
            situation: "On 7 October 2026 Khadija Oubella roasts sack TF-0412 in the clay pan for culinary oil: twelve minutes. A helper nudges the card to twenty before Khadija sees it.",
            teaches: [
                "An edit to a saved card waits in the context until the next save.",
                "rollback() puts the card back to its saved values."
            ]
        ) {
            if let roast = roasts.first {
                RoastFields(roast: roast)
                Section {
                    LabeledContent("On the card", value: "\(roast.panMinutes) minutes")
                    LabeledContent("hasChanges", value: String(modelContext.hasChanges))
                    Button("Put the card back", role: .destructive) { modelContext.rollback() }
                        .disabled(!modelContext.hasChanges)
                    Button("Keep the new minutes") { try? modelContext.save() }
                        .disabled(!modelContext.hasChanges)
                }
            } else {
                Button("File Khadija's roast") {
                    modelContext.insert(KernelRoast(roastCode: "TF-0412-R", roasterName: "Khadija Oubella", panMinutes: 12, forCulinaryOil: true))
                    try? modelContext.save()
                }
            }
        }
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
