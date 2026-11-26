# ModelContext · 06 · Amazir press transaction

On 10 October Youssef drains a drum and bags press cake together; the next run's scale jams.

**What it teaches**

- transaction runs its closure and saves what the closure changed.
- If the transaction throws, nothing from that closure is saved.

**Files**

| File | Role |
| --- | --- |
| [`OilDrum.swift`](OilDrum.swift) | The model and its SwiftUI screen |

**Try it**

Open Amazir press transaction. Drain AM-1009, then drain AM-1010 on the jammed scale. Only the first run is filed.

`swift test` locks the lesson in `throwingTransactionSavesNothing`.
