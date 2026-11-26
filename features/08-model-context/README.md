# ModelContext

Insert, save, autosave, and rollback.

Official reference: [ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext).

The thirteen screens follow argan oil from Coopérative Tifawin in Tamanar through Huilerie Amazir in Essaouira, Atelier Zitoun and the Rahba Kedima spice shops in Marrakech, and Maison d'Argane in Casablanca. Each screen opens its own in-memory store. Business and place names form the catalog's fictional chain in these real places.

On 5 October 2026 Fadma Aït Brahim cracks 9.5 kilos of kernels. On 6 October the sack roll is corrected. On 7 October Khadija Oubella roasts for culinary oil and throws out a scorched pan. On 9–11 October Youssef Bennani presses, drains, and bottles in Essaouira. On 13–14 October Salma Idrissi works cream batches and purges soap labels in Marrakech. On 16–18 October Hamid Ouazzani reprices, sells, and dispatches from Rahba Kedima. On 20 October Leila Amrani closes the Casablanca morning folder.

## Examples (13 of 13 bottled)

01. [Tamanar cracking tally](01-tamanar-cracking-tally/) — available
02. [Tifawin sack roll](02-tifawin-sack-roll/) — available
03. [Tifawin roast card](03-tifawin-roast-card/) — available
04. [Tifawin scorched pan](04-tifawin-scorched-pan/) — available
05. [Essaouira press autosave](05-essaouira-press-autosave/) — available
06. [Amazir press transaction](06-amazir-press-transaction/) — available
07. [Amazir bottle rack](07-amazir-bottle-rack/) — available
08. [Zitoun save ledger](08-zitoun-save-ledger/) — available
09. [Zitoun label purge](09-zitoun-label-purge/) — available
10. [Rahba shelf reprice](10-rahba-shelf-reprice/) — available
11. [Rahba two desks](11-rahba-two-desks/) — available
12. [Medina courier slip](12-medina-courier-slip/) — available
13. [Casablanca morning folder](13-casablanca-morning-folder/) — available

## What each scenario adds

| Slot | Context behavior / Swift idiom |
| --- | --- |
| 01 | insert / save / hasChanges |
| 02 | insertedModelsArray / changedModelsArray / deletedModelsArray |
| 03 | rollback after edit, @Bindable Stepper |
| 04 | rollback of unsaved insert, ModelContext extension |
| 05 | autosaveEnabled defaults, modelContainer(for:inMemory:), TimelineView |
| 06 | transaction, throwing Error, two models |
| 07 | delete + rollback, List onDelete |
| 08 | ModelContext.didSave, onReceive, PersistentIdentifier arrays |
| 09 | delete(model:where:), #Predicate |
| 10 | enumerate(batchSize:), FetchDescriptor predicate |
| 11 | Two ModelContexts, registeredModel |
| 12 | registeredModel vs model(for:) |
| 13 | @ModelActor morning folder, Codable handover |

The shared `MemoryStore`, `inMemoryStore(for:)`, `ScratchFolder`, fresh-read helpers, `GregorianDay`, and `ScenarioChrome` carry setup and presentation where a scenario uses them. Tests live in `Tests/SwiftDataMultivitaminTests/`, one lesson test per slot, and use fresh contexts to read saved values.

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a later feature.

