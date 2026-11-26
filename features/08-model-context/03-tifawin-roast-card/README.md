# ModelContext · 03 · Tifawin roast card

On 7 October 2026 Khadija Oubella roasts sack TF-0412 for twelve minutes; a helper nudges the card to twenty.

**What it teaches**

- Changing pan minutes marks the context changed.
- rollback() clears hasChanges, but the open card keeps the new minutes; a fresh fetch still reads the filed value.

**Files**

| File | Role |
| --- | --- |
| [`KernelRoast.swift`](KernelRoast.swift) | The model and its SwiftUI screen |

**Try it**

Open Tifawin roast card. File the roast, nudge the minutes, then roll back. The open card keeps 20; filed minutes stay 12.

`swift test` locks the lesson in `rollbackClearsHasChangesButKeepsOpenMinutes`.
