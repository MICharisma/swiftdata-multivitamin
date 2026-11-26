# ModelContext · 04 · Tifawin scorched pan

Later on 7 October a second pan scorches. The batch was never saved.

**What it teaches**

- rollback() drops an unsaved insert from the context.
- The object keeps the values it had. modelContext on that object becomes nil.

**Files**

| File | Role |
| --- | --- |
| [`PanBatch.swift`](PanBatch.swift) | The model and its SwiftUI screen |

**Try it**

Open Tifawin scorched pan. Start the second pan and throw it out. The context holds no batches; the loose card still shows 6 kilos.

`swift test` locks the lesson in `rollbackDropsAnUnsavedInsert`.
