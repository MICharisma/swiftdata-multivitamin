# ModelContainer and ModelConfiguration · 10 · Gaia blend trial

On 27 April 2026 Helena Sarmento pours morning blend trials, clears the book, and starts the afternoon trial.

**What it teaches**

- delete(model:) with no predicate removes every sample in the trial book.
- The same container takes the afternoon trial without being reopened.

**Files**

| File | Role |
| --- | --- |
| [`BlendSample.swift`](BlendSample.swift) | The model and its SwiftUI screen |

**Try it**

Open Gaia blend trial. Pour the morning trial, clear it with delete(model:), then pour the afternoon trial.

`swift test` locks the lesson in `deleteAllDataClearsTheTrialBook`.
