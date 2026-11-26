# ModelContext · 05 · Essaouira press autosave

On 9 October 2026 Youssef Bennani presses the roast at Huilerie Amazir in Essaouira without tapping save.

**What it teaches**

- Both the main context and a ModelContext you make start with autosave on.
- Setting autosaveEnabled to false makes the press book wait for an explicit save.

**Files**

| File | Role |
| --- | --- |
| [`PressRun.swift`](PressRun.swift) | The model and its SwiftUI screen |

**Try it**

Open Essaouira press autosave. Note both defaults are on, press with autosave off, then save. The run is filed only after save.

`swift test` locks the lesson in `mainContextAutosavesByDefault`.
