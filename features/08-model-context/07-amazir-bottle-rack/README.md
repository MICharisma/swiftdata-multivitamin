# ModelContext · 07 · Amazir bottle rack

On 11 October an apprentice swipes bottle AM-1009-02 off the rack by mistake.

**What it teaches**

- delete marks a saved bottle. The store keeps it until the next save.
- rollback() takes the mark off, and the bottle is back on the rack.

**Files**

| File | Role |
| --- | --- |
| [`RackBottle.swift`](RackBottle.swift) | The model and its SwiftUI screen |

**Try it**

Open Amazir bottle rack. Bottle the morning run, swipe a bottle, then put it back. The store still holds three until you confirm.

`swift test` locks the lesson in `deleteWaitsForSaveAndRollbackUndoesIt`.
