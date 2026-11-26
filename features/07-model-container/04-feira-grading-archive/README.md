# ModelContainer and ModelConfiguration · 04 · Feira grading archive

On 2 March 2026 Filipa Moura of Rolhas Vasconcelos in Santa Maria da Feira opens last season's grading file before grading the Sorraia planks.

**What it teaches**

- allowsSave: false opens an existing store file for reading.
- A save through that container throws, and the file keeps last season's grades.

**Files**

| File | Role |
| --- | --- |
| [`GradingSheet.swift`](GradingSheet.swift) | The model and its SwiftUI screen |

**Try it**

Open Feira grading archive. Try to regrade RV-2507. The save is refused and the sheet stays Superior.

`swift test` locks the lesson in `readOnlyArchiveRefusesASave`.
