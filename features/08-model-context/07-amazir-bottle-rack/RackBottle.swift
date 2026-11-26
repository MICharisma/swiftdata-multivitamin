// Feature: ModelContext
// Slot 07 — Amazir bottle rack
// Teaches:
// - delete marks a saved bottle. The store keeps it until the next save.
// - rollback() takes the mark off, and the bottle is back on the rack.

import SwiftData
import SwiftUI

@Model
final class RackBottle {
    var bottleCode: String
    var millilitres: Int
    var grade: String

    init(bottleCode: String, millilitres: Int, grade: String) {
        self.bottleCode = bottleCode
        self.millilitres = millilitres
        self.grade = grade
    }
}

enum AmazirRack {
    static let morningBottling: [(code: String, millilitres: Int)] = [
        ("AM-1009-01", 250), ("AM-1009-02", 250), ("AM-1009-03", 500)
    ]

    static func bottle(into context: ModelContext) throws {
        for (code, millilitres) in morningBottling {
            context.insert(RackBottle(bottleCode: code, millilitres: millilitres, grade: "Culinary, roasted"))
        }
        try context.save()
    }
}

struct RackBottleScreen: View {
    var body: some View {
        BottleRackDesk().inMemoryStore(for: RackBottle.self)
    }
}

private struct BottleRackDesk: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RackBottle.bottleCode) private var bottles: [RackBottle]
    @State private var filedCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("On 11 October 2026 Youssef's apprentice tidies the rack at Huilerie Amazir and swipes away bottle AM-1009-02, which is promised to Atelier Zitoun in Marrakech.")
                .foregroundStyle(.secondary)
            List {
                ForEach(bottles) { bottle in
                    LabeledContent(bottle.bottleCode, value: "\(bottle.millilitres) ml · \(bottle.grade)")
                }
                .onDelete { offsets in
                    offsets.map { bottles[$0] }.forEach(modelContext.delete)
                    refreshFiledCount()
                }
            }
            .frame(minHeight: 160)
            HStack {
                Button("Bottle the morning run") {
                    try? AmazirRack.bottle(into: modelContext)
                    refreshFiledCount()
                }
                .disabled(!bottles.isEmpty || modelContext.hasChanges)
                Button("Put the bottle back") {
                    modelContext.rollback()
                    refreshFiledCount()
                }
                Button("Confirm the rack") {
                    try? modelContext.save()
                    refreshFiledCount()
                }
            }
            LabeledContent("Bottles filed in the store", value: "\(filedCount)")
            Text("Teaches: delete marks a saved bottle and the store keeps it until the next save; rollback() takes the mark off.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Amazir bottle rack")
    }

    private func refreshFiledCount() {
        filedCount = (try? modelContext.freshCount(RackBottle.self)) ?? 0
    }
}
