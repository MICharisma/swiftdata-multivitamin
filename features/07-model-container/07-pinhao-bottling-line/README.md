# ModelContainer and ModelConfiguration · 07 · Pinhão bottling line

On 6 April 2026 Tiago Rebelo bottles the 2022 vintage at Quinta do Vale Escuro in Pinhão on the filler, corker, and label table.

**What it teaches**

- A second container with the same in-memory configuration name still opens empty.
- Only the container that saved can see the filler's pass.

**Files**

| File | Role |
| --- | --- |
| [`BottlingPass.swift`](BottlingPass.swift) | The model and its SwiftUI screen |

**Try it**

Open Pinhão bottling line. Run the filler, then ask each station. Only the filler sees its pass; the corker's same-named store is empty.

`swift test` locks the lesson in `sameMemoryNameStillOpensEmpty`.
