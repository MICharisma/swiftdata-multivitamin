# ModelContext · 05 · Essaouira press autosave

On 9 October 2026 Youssef Bennani presses the roast at Huilerie Amazir in Essaouira without tapping save.

**What it teaches**

- The main context from modelContainer(for:inMemory:) autosaves by default.
- A ModelContext you make yourself starts with autosave off.

**Files**

| File | Role |
| --- | --- |
| [`PressRun.swift`](PressRun.swift) | The model and its SwiftUI screen |

**Try it**

Open Essaouira press autosave. Press the run and watch the filed count climb without an explicit save.

`swift test` locks the lesson in `mainContextAutosavesByDefault`.
