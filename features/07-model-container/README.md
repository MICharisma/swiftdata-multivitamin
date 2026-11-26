# ModelContainer and ModelConfiguration

Where a store lives, in memory or on disk, and how it is opened.

Official references: [ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer), [ModelConfiguration](https://developer.apple.com/documentation/swiftdata/modelconfiguration), and [ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext).

The thirteen screens follow cork from the oaks at Herdade do Sobral near Coruche through boiling at Corticeira do Sorraia, punching and branding at Rolhas Vasconcelos in Santa Maria da Feira, bottling at Quinta do Vale Escuro in Pinhão, lodging at Caves Sarmento in Vila Nova de Gaia, and the shelf at Garrafeira do Bonfim in Porto, ending at Tasca da Graça in Lisbon. Each screen opens its own store. Business and place names form the catalog's fictional chain in these real places.

On 14 July 2025 Joaquim Pires strips row 14; on 18 July Manuel Cardoso stacks the bark. On 9 February 2026 Ana Ribeiro boils batch C-14. On 2 March Filipa Moura opens last season's grading archive; on 9 March Bruno Sá punches stoppers; on 12 March Carla Neves brands them for Vale Escuro. On 6–7 April Tiago Rebelo bottles and cellars the vintage. On 20 April Helena Sarmento enters the lodge register; on 27 April she clears a blend trial. On 4–5 May Rui Teixeira shelves and sells at Bonfim. On 9 May Marta Lobo lays out the Lisbon morning folder.

## Examples (13 of 13 bottled)

01. [Coruche bark tally](01-coruche-bark-tally/) — available
02. [Sobral stack book](02-sobral-stack-book/) — available
03. [Sorraia boiling yard](03-sorraia-boiling-yard/) — available
04. [Feira grading archive](04-feira-grading-archive/) — available
05. [Feira punching floor](05-feira-punching-floor/) — available
06. [Feira print room](06-feira-print-room/) — available
07. [Pinhão bottling line](07-pinhao-bottling-line/) — available
08. [Vale Escuro cellar book](08-vale-escuro-cellar-book/) — available
09. [Gaia lodge register](09-gaia-lodge-register/) — available
10. [Gaia blend trial](10-gaia-blend-trial/) — available
11. [Bonfim shelf books](11-bonfim-shelf-books/) — available
12. [Bonfim till and stockroom](12-bonfim-till-and-stockroom/) — available
13. [Lisbon morning folder](13-lisbon-morning-folder/) — available

## What each scenario adds

| Slot | Container / configuration behavior / Swift idiom |
| --- | --- |
| 01 | ModelContainer(for:configurations:), Result, @Query |
| 02 | ModelConfiguration(url:), property wrapper, reopened file |
| 03 | Related models enter the schema, Grid |
| 04 | allowsSave: false, Result.regrade refusal |
| 05 | Two configurations, result builder |
| 06 | Configuration as a value, Table |
| 07 | Shared vs distinct in-memory names, generics |
| 08 | Sendable container, actor, async let |
| 09 | Schema.Version, lazy filter + KeyPath |
| 10 | deleteAllData(), @Observable book |
| 11 | Associated-value enum → configuration, switch expression |
| 12 | Two containers on one file, KeyPath read |
| 13 | File + memory shelves, morning folder |

The shared `MemoryStore`, `inMemoryStore(for:)`, `ScratchFolder`, fresh-read helpers, `GregorianDay`, and `ScenarioChrome` carry setup and presentation where a scenario uses them. Tests live in `Tests/SwiftDataMultivitaminTests/`, one lesson test per slot, and use fresh contexts to read saved values.

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a later feature.

