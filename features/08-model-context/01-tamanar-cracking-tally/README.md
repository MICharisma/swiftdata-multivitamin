# ModelContext · 01 · Tamanar cracking tally

On 5 October 2026 Fadma Aït Brahim cracks argan nuts at Coopérative Tifawin in Tamanar and tallies 9.5 kilos of kernels.

**What it teaches**

- insert puts the tally in the context, and hasChanges turns true.
- save writes it to the store, and hasChanges turns false.

**Files**

| File | Role |
| --- | --- |
| [`CrackingTally.swift`](CrackingTally.swift) | The model and its SwiftUI screen |

**Try it**

Open Tamanar cracking tally. Insert Fadma's tally, then save. hasChanges flips true then false; the filed count becomes 1.

`swift test` locks the lesson in `insertSetsHasChangesAndSaveClearsIt`.
