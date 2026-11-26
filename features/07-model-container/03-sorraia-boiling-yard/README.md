# ModelContainer and ModelConfiguration · 03 · Sorraia boiling yard

On 9 February 2026 Ana Ribeiro of Corticeira do Sorraia boils stack P-14 as batch C-14.

**What it teaches**

- Naming one model brings every model it relates to into the container's schema.
- The boiled planks can be fetched though the container was opened for the batch.

**Files**

| File | Role |
| --- | --- |
| [`BoilingBatch.swift`](BoilingBatch.swift) | The model and its SwiftUI screen |

**Try it**

Open Sorraia boiling yard. Boil batch C-14. The schema lists BoilingBatch and BoiledPlank together.

`swift test` locks the lesson in `boilingBookPullsRelatedPlanksIntoTheSchema`.
