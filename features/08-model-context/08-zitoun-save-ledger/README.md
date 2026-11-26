# ModelContext · 08 · Zitoun save ledger

On 13 October Salma Idrissi of Atelier Zitoun mixes cream and soap, revises the cream, and pulls the soap.

**What it teaches**

- Each save posts ModelContext.didSave with the identifiers it inserted, updated, and deleted.
- The notification's userInfo carries PersistentIdentifier arrays, not the models.

**Files**

| File | Role |
| --- | --- |
| [`CreamBatch.swift`](CreamBatch.swift) | The model and its SwiftUI screen |

**Try it**

Open Zitoun save ledger. Work the morning batches. Three didSave receipts show insert, update, and delete counts.

`swift test` locks the lesson in `didSaveCarriesIdentifierArrays`.
