# ModelContainer and ModelConfiguration · 01 · Coruche bark tally

On 14 July 2025 Joaquim Pires strips row 14 at Herdade do Sobral, outside Coruche. Manuel Cardoso weighs 42 arrobas on the cart.

**What it teaches**

- A container is opened from a model type and a configuration.
- An in-memory configuration gives each container its own empty store.

**Files**

| File | Role |
| --- | --- |
| [`BarkTally.swift`](BarkTally.swift) | The model and its SwiftUI screen |

**Try it**

Open Coruche bark tally. Weigh Joaquim's cart. The tally appears under the in-memory store line.

`swift test` locks the lesson in `barkTallyOpensAnInMemoryContainer`.
