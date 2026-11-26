# ModelContainer and ModelConfiguration · 08 · Vale Escuro cellar book

On 7 April 2026 two cellar hands count the east and west aisles while Tiago watches the book.

**What it teaches**

- A ModelContainer is Sendable. An actor can keep one and make its own contexts.
- Saves from those contexts land in the store the main context reads.

**Files**

| File | Role |
| --- | --- |
| [`CellarPallet.swift`](CellarPallet.swift) | The model and its SwiftUI screen |

**Try it**

Open Vale Escuro cellar book. Count both aisles. The four pallets appear in the main book.

`swift test` locks the lesson in `sendableContainerAcceptsActorSaves`.
