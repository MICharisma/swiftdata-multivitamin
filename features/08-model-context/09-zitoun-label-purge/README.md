# ModelContext · 09 · Zitoun label purge

On 14 October the soap labels have to leave the print run before the courier to Rahba Kedima.

**What it teaches**

- delete(model:where:) removes every label that matches a predicate, without fetching them first.
- The matching labels are gone from the store as soon as delete(model:where:) returns.

**Files**

| File | Role |
| --- | --- |
| [`ProductLabel.swift`](ProductLabel.swift) | The model and its SwiftUI screen |

**Try it**

Open Zitoun label purge. Print, then purge ZT-312. The store loses the soap labels as soon as the purge returns.

`swift test` locks the lesson in `predicateDeleteRemovesMatchingRowsAtOnce`.
