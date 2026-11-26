# ModelContainer and ModelConfiguration · 05 · Feira punching floor

On 9 March 2026 Bruno Sá punches 24,000 stoppers and fills reject sack RJ-0309 for the granulate line.

**What it teaches**

- One container can hold two configurations, each with its own schema and file.
- Each model is saved to the file whose configuration lists it.

**Files**

| File | Role |
| --- | --- |
| [`PunchRun.swift`](PunchRun.swift) | The model and its SwiftUI screen |

**Try it**

Open Feira punching floor. Close the punching shift. Each file holds only its own model.

`swift test` locks the lesson in `twoConfigurationsWriteSeparateFiles`.
