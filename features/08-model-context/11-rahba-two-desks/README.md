# ModelContext · 11 · Rahba two desks

On 17 October Hamid sells two bottles from Nadia's order while his nephew holds the same order at the back desk.

**What it teaches**

- Two contexts on one container each hold their own copy of a saved jar order.
- Saving in one context does not rewrite the other context's held object until that context fetches again.

**Files**

| File | Role |
| --- | --- |
| [`JarOrder.swift`](JarOrder.swift) | The model and its SwiftUI screen |

**Try it**

Open Rahba two desks. Sell two from the counter. The held back-desk object stays at 4 until a refetch.

`swift test` locks the lesson in `heldObjectStaysStaleAcrossContexts`.
