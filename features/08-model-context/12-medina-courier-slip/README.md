# ModelContext · 12 · Medina courier slip

On 18 October a courier collects two bottles for Riad des Oliviers; the warehouse desk looks up slip CK-18 by identifier.

**What it teaches**

- registeredModel(for:) returns the slip only if this context already holds it.
- model(for:) materializes the slip from the store when the context does not yet hold it.

**Files**

| File | Role |
| --- | --- |
| [`CourierSlip.swift`](CourierSlip.swift) | The model and its SwiftUI screen |

**Try it**

Open Medina courier slip. File the slip and ask the warehouse desk. registeredModel is nil until model(for:) materializes it.

`swift test` locks the lesson in `modelForMaterializesAndRegisteredDoesNot`.
