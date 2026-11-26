# ModelContainer and ModelConfiguration · 13 · Lisbon morning folder

On 9 May 2026 Marta Lobo lays out the morning folder at Tasca da Graça: cellar list and cork row in the file, pour notes in memory.

**What it teaches**

- One container can join a store file and an in-memory store, each for its own models.
- Reopening the file brings back the cellar list and the cork's row. The pour notes were never in it.

**Files**

| File | Role |
| --- | --- |
| [`CellarListing.swift`](CellarListing.swift) | The model and its SwiftUI screen |

**Try it**

Open Lisbon morning folder. Lay out the morning folder. The reopened file has the cellar list and cork row, and no pour notes.

`swift test` locks the lesson in `fileAndMemoryShelvesSplitOnReopen`.
