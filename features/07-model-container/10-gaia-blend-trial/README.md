# ModelContainer and ModelConfiguration · 10 · Gaia blend trial

On 27 April 2026 Helena Sarmento pours morning blend trials, clears the book, and starts the afternoon trial.

**What it teaches**

- On macOS 15 and later, deleteAllData() empties the container's store.
- The same container takes the next trial's samples without being reopened.

**Files**

| File | Role |
| --- | --- |
| [`BlendSample.swift`](BlendSample.swift) | The model and its SwiftUI screen |

**Try it**

Open Gaia blend trial. Pour the morning trial, pour it away, then pour the afternoon trial.

`swift test` locks the lesson in `deleteAllDataClearsTheTrialBook`.
