# Discoveries

Non-obvious SwiftData behaviors found while bottling this catalog. Every
entry needs a test in this repository that shows it. Nothing is written
here from the docs alone, and nothing is written here until a test has
shown it.

Each entry has a short title, what happens, why it matters, what to do
about it, and a link to the scenario that shows it.

## Attributes

### A second insert with the same unique value overwrites the first row

**What happens.** Two `ShearingLicense` values with ear mark `LQ-184` are inserted, and each insert is saved. The second save throws nothing. A fetch returns one row. That row's `persistentModelID` is the first object's id. The first object's `conditionNote` is now the second card's note, "Cut on the left shoulder".

**Why it matters.** A clerk who expects the book to refuse a duplicate mark will instead replace the condition on the license already on the nail.

**What to do.** Save the first license, then treat a second insert with that mark as an edit of the existing row. Read the row back after the save.

Shown in [Lucanas second card](features/02-attributes/12-lucanas-second-card/).

### A property with no original name stores an empty string

**What happens.** `ScouredWeight.scouredKilos` is declared `@Attribute(originalName: "fleeceKilos")`. Its schema attribute has `originalName` `fleeceKilos` and `name` `scouredKilos`. `lotCode` on the same model has no `originalName` argument. Its schema attribute has `originalName` `""`.

**Why it matters.** Comparing `originalName` with `name` does not tell you whether the column was renamed. Every unmarked property fails that comparison, because the stored original name is empty rather than the current name.

**What to do.** Treat a non-empty `originalName` as the previous column name.

Shown in [Arequipa renamed kilos](features/02-attributes/06-arequipa-renamed-kilos/).

### An ephemeral attribute is not transient, and the value is absent after save

**What happens.** `ShawlCounter.spokenMarkup` is `@Attribute(.ephemeral)` with default `""`. The schema option list contains `ephemeral`. `isTransient` is false. The card is saved with spoken markup "Add forty bolivianos" and asking price 920. A new context fetches asking price 920 and spoken markup `""`.

**Why it matters.** A counter copy that reads `isTransient` will treat the spoken line as a stored column. The filed book does not contain it.

**What to do.** Give the ephemeral property a default. Read the option. After save, read the row from a new context when you need the filed value.

Shown in [La Paz spoken markup](features/02-attributes/08-la-paz-spoken-markup/).

## Relationships

### A to-many whose maximum is 0 still holds every note

**What happens.** `Fruitiere.notes` is declared `@Relationship` with no count arguments. The schema stores `minimumModelCount` 0 and `maximumModelCount` 0. The Pellier note and the Gaillard note are both appended. Both stay on the roll, and each note names the plateau fruitière.

**Why it matters.** A clerk who reads 0 as "this roll holds nothing" will think the morning deliveries were refused.

**What to do.** Treat 0 on a relationship that carries `@Relationship` as the omitted count. Count the models when you need the size of the roll.

Shown in [Plateau roll](features/03-relationships/02-plateau-roll/).

### A second unique board takes the wheel and leaves the first board in the store

**What happens.** `SpruceBoard.wheel` is `@Relationship(.unique)` with `maximumModelCount` 1. Board SP-1 is given wheel PL-19. Board SP-2 is then given that same wheel. SP-1's wheel becomes nil. SP-2 carries PL-19. The save throws nothing. A fetch returns both boards.

**Why it matters.** Unique does not refuse the second board, and it does not delete the first one. The wheel moves.

**What to do.** After the second assignment, read both boards. The earlier board is still a row.

Shown in [Champagnole spruce board](features/03-relationships/06-champagnole-spruce-board/).

### A buyer minimum of 1 still files a card with no buyer

**What happens.** `SupperOrder.buyer` is `@Relationship(minimumModelCount: 1)`. `SupperBuyer` has no relationship back, so `inverseName` is nil. The card is saved with no buyer. The save throws nothing. A new context fetches one card, and its buyer is nil.

**Why it matters.** The minimum is a stored count. It does not stop the save.

**What to do.** Read `minimumModelCount` from the schema. If the card must name a buyer, check the relationship before saving.

Shown in [Besançon supper card](features/03-relationships/07-besancon-supper-card/).

### An inverse stores its own name as the original name

**What happens.** `CheeseRack.wheels` is `@Relationship(originalName: "meules")`. Its original name is `meules`. `RackWheel.rack` is the inverse and does not carry `@Relationship`. Its original name is `rack`. `RackWheel.label` carries `@Relationship` and omits `originalName`. Its original name is `""`. `ShelfLabel.wheel`, the inverse of that label, stores `wheel`.

**Why it matters.** An empty original name means the macro omitted it. An inverse's own name in that field does not mean the relationship was renamed.

**What to do.** Treat a non-empty original name as a previous name on the relationship that carries `@Relationship`. On an inverse that does not carry the macro, the stored original name is the property name.

Shown in [Rousses renamed rack](features/03-relationships/10-rousses-renamed-rack/).

## Delete rules

### A deny rule still saves the deletion

**What happens.** `CopperStill.cooks` is `@Relationship(deleteRule: .deny)`. Cook QS-22 is on that list. The still is deleted and the context is saved. The save throws nothing. A new context finds no still. It finds the cook, and the cook's still line is empty.

**Why it matters.** The rule name says the deletion should be refused while a cook is charged. This store deletes the still anyway.

**What to do.** Read `deleteRule` when you need the stored mark. After the save, fetch the cook if the desk still needs it. Do not treat deny as a guard in this store.

Shown in [Qamsar copper still](features/04-delete-rules/06-qamsar-copper-still/).

### A noAction rule leaves the related mark with an empty link

**What happens.** `WallTally.marks` is `@Relationship(deleteRule: .noAction)`. The tally is deleted and the context is saved. The save throws nothing. A new context finds no tally. It finds chalk mark QS-22, and that mark's tally is nil.

**Why it matters.** No action does not leave the mark pointing at the deleted tally. The link is empty, and the mark stays.

**What to do.** Read the stored rule when the name matters. After the save, read the mark from a new context. Its tally line is empty.

Shown in [Qamsar wall tally](features/04-delete-rules/07-qamsar-wall-tally/).

## Transient

### A transient property can hold a type that is not a column

**What happens.** `LatticeBowl.scratch` is `@Transient`. Its type is `LatticeScratch`, an enum whose `marked` case carries `openings` and `note`. The schema properties are `bowlName`, `carvedOn`, and `carverName`. The bowl is saved with 14 openings and the note "Stop before the grey". A new context reads bowl name "Lattice egg" and the `.blank` default: 0 openings and an empty note. The open card still has 14 and the note.

**Why it matters.** That enum has no transformer, is not `Codable`, and is not a stored attribute. Marked transient, it never becomes a column, and the container still opens.

**What to do.** Put the working tally on `@Transient` with a default. Read it from the open card. Read the bowl name from a new context when the desk needs the filed row.

Shown in [Lattice scratch](features/05-transient/05-lattice-scratch/).

### Writing a transient property does not mark the context changed

**What happens.** `BedestenCard` is saved at 4000 lira. The aside is then set to "Emre will collect at dusk". `hasChanges` is false. A second save leaves the fetched price at 4000. A new context reads an empty aside. The open card still has the sentence.

**Why it matters.** A desk that saves only when the context is dirty will not pick up a muttered aside. The aside also never lands in the row.

**What to do.** Keep the aside on the open card. Change a stored property when the book should record something.

Shown in [Bedesten aside](features/05-transient/07-bedesten-aside/).

## ModelContainer and ModelConfiguration

### A second container with the same in-memory configuration name still opens empty

**What happens.** The filler opens `ModelConfiguration("pinhao-line", isStoredInMemoryOnly: true)`, inserts a bottling pass, and saves. The corker opens another container with that same configuration name. A fetch on the corker's context returns no passes. The label table, named `pinhao-labels`, also returns none.

**Why it matters.** Reusing an in-memory configuration name does not join two containers. Each `ModelContainer` keeps its own store.

**What to do.** Keep one container and make contexts from it when stations must share a book.

Shown in [Pinhão bottling line](features/07-model-container/07-pinhao-bottling-line/).

### A model held in one container does not refresh when another container saves the same file

**What happens.** The till and the stockroom each open a `ModelContainer` on the Bonfim stock file. The till inserts six bottles and saves. The stockroom fetches that card and holds it. The till sells two bottles and saves. The held stockroom card still shows 6. A new context on the stockroom container shows 4.

**Why it matters.** Opening the same file in two containers does not keep live objects in step. A desk that keeps a card on screen will show a stale count.

**What to do.** Fetch again after the other container may have saved, or share one container and use two contexts.

Shown in [Bonfim till and stockroom](features/07-model-container/12-bonfim-till-and-stockroom/).

## ModelContext

### Both the main context and a ModelContext you make start with autosave on

**What happens.** A container opened with an in-memory configuration has `mainContext.autosaveEnabled` true. `ModelContext(container)` also has `autosaveEnabled` true. After `autosaveEnabled` is set to false, an insert leaves `hasChanges` true, and a fresh context counts 0 rows until `save()`.

**Why it matters.** Code that builds its own context still autosaves unless it turns the flag off. The catalog's `MemoryStore` turns it off so every save is visible.

**What to do.** Set `autosaveEnabled = false` when the desk should wait for an explicit save.

Shown in [Essaouira press autosave](features/08-model-context/05-essaouira-press-autosave/).

### rollback() clears hasChanges but leaves the open card's edited value

**What happens.** Khadija's roast is saved at 12 pan minutes. The open card is set to 20. `hasChanges` is true. `rollback()` makes `hasChanges` false. The open card still shows 20. A fresh context reads 12.

**Why it matters.** Rolling back does not rewrite the property on the instance you hold. A screen bound to that instance will keep showing the edited minutes.

**What to do.** Read the filed value from a new context after rollback, or set the property back yourself.

Shown in [Tifawin roast card](features/08-model-context/03-tifawin-roast-card/).

### delete(model:where:) removes matching rows without a separate save

**What happens.** Five labels are filed. `delete(model:where:)` runs for batch ZT-312. A fetch in the same context returns three labels. A fresh context also returns three, with no `save()` in between.

**Why it matters.** A desk that expects the purge to wait for save will think the soap labels are still in the store.

**What to do.** Treat `delete(model:where:)` as already filed when it returns.

Shown in [Zitoun label purge](features/08-model-context/09-zitoun-label-purge/).

### A context's held object stays stale when another context on the same container saves

**What happens.** The counter and the back desk are two `ModelContext`s on one container. The counter opens Nadia's order for 4 jars and saves. The back desk fetches that order and holds it. The counter sells two jars and saves. The held back-desk object still shows 4. A refetch on the back desk shows 2.

**Why it matters.** Two contexts share a store, not live property values. A screen that keeps an object without refetching will show the old count.

**What to do.** Refetch after the other context may have saved, or edit through the context that holds the object you display.

Shown in [Rahba two desks](features/08-model-context/11-rahba-two-desks/).
