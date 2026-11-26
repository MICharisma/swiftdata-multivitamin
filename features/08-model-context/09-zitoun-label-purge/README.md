# ModelContext · 09 · Zitoun label purge

On 14 October the soap labels have to leave the print run before the courier to Rahba Kedima.

**What it teaches**

- delete(model:where:) removes every label that matches a predicate, without fetching them first.
- The purge waits for save before the store loses the matching labels.

**Files**

| File | Role |
| --- | --- |
| [`ProductLabel.swift`](ProductLabel.swift) | The model and its SwiftUI screen |

**Try it**

Open Zitoun label purge. Print, purge ZT-312, then save. The store loses the soap labels only after save.

`swift test` locks the lesson in `predicateDeleteWaitsForSave`.
