# ModelContext · 02 · Tifawin sack roll

On 6 October 2026 the cooperative reweighs, tears, and fills sacks before the roaster arrives.

**What it teaches**

- Before a save, the context lists what it will insert, change, and delete.
- After the save, all three lists are empty.

**Files**

| File | Role |
| --- | --- |
| [`KernelSack.swift`](KernelSack.swift) | The model and its SwiftUI screen |

**Try it**

Open Tifawin sack roll. Make the morning's changes, then save. The pending lists fill and then empty.

`swift test` locks the lesson in `pendingArraysClearAfterSave`.
