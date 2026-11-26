# ModelContext · 03 · Tifawin roast card

On 7 October 2026 Khadija Oubella roasts sack TF-0412 for twelve minutes; a helper nudges the card to twenty.

**What it teaches**

- An edit to a saved card waits in the context until the next save.
- rollback() puts the card back to its saved values.

**Files**

| File | Role |
| --- | --- |
| [`RoastCard.swift`](RoastCard.swift) | The model and its SwiftUI screen |

**Try it**

Open Tifawin roast card. File the roast, nudge the minutes, then put the card back. The minutes return to 12.

`swift test` locks the lesson in `rollbackRestoresSavedPanMinutes`.
