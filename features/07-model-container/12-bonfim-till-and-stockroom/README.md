# ModelContainer and ModelConfiguration · 12 · Bonfim till and stockroom

On 5 May 2026 Marta Lobo buys two bottles at the Bonfim till while the stockroom laptop holds the same file open.

**What it teaches**

- Two containers can open the same store file.
- A model already held in one container does not refresh when the other container saves; a new context does.

**Files**

| File | Role |
| --- | --- |
| [`StockCard.swift`](StockCard.swift) | The model and its SwiftUI screen |

**Try it**

Open Bonfim till and stockroom. Ring up two bottles. The held card stays at 6; a new context reads 4.

`swift test` locks the lesson in `heldCardDoesNotRefreshAcrossContainers`.
