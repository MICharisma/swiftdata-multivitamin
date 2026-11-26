# ModelContext · 10 · Rahba shelf reprice

On 16 October Hamid Ouazzani raises every argan jar by 10 dirhams at his Rahba Kedima shop.

**What it teaches**

- enumerate walks a fetch in batches and hands each jar to a closure.
- Edits made during the walk wait for an explicit save.

**Files**

| File | Role |
| --- | --- |
| [`SpiceJar.swift`](SpiceJar.swift) | The model and its SwiftUI screen |

**Try it**

Open Rahba shelf reprice. Stock the shelf, raise argan jars, then save. The walk edits wait for save.

`swift test` locks the lesson in `enumerateEditsWaitForSave`.
