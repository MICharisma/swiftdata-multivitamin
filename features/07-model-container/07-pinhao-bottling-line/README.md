# ModelContainer and ModelConfiguration · 07 · Pinhão bottling line

On 6 April 2026 Tiago Rebelo bottles the 2022 vintage at Quinta do Vale Escuro in Pinhão on the filler, corker, and label table.

**What it teaches**

- Two containers that name the same in-memory configuration share that store.
- A different configuration name opens a separate empty store.

**Files**

| File | Role |
| --- | --- |
| [`BottlingPass.swift`](BottlingPass.swift) | The model and its SwiftUI screen |

**Try it**

Open Pinhão bottling line. Run the filler, then ask each station. Filler and corker share the store; the label table does not.

`swift test` locks the lesson in `sameMemoryNameSharesAStore`.
