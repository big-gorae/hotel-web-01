# Hotel Web 01

Godot 4 GDScript starter for a 2.5D photo-based point-and-click hotel game.

## Files

- `resource/images/front_desk.png`: hotel front desk
- `resource/images/corridor.png`: outside corridor
- `resource/images/room_105_door_window.png`: room 105 door and window angle
- `resource/images/room_105_bathroom_entry.png`: room 105 bathroom entry angle
- `resource/images/room_105_bathroom.png`: room 105 bathroom
- `resource/images/room_105_bathroom_curtain_closed.png`: room 105 bathroom with the shower curtain closed
- `resource/images/room_106_bed_bathroom_entry.png`: room 106 bed and bathroom entry angle
- `resource/images/room_106_bathroom.png`: room 106 reused bathroom angle
- `resource/images/room_106_bathroom_curtain_closed.png`: room 106 bathroom with the shower curtain closed
- `resource/images/room_107_bed_nightstand.png`: room 107 bed and nightstand angle
- `resource/images/room_107_bathroom_entry.png`: room 107 bathroom entry angle
- `resource/images/room_107_bathroom.png`: room 107 reused bathroom angle
- `resource/images/room_107_bathroom_curtain_closed.png`: room 107 bathroom with the shower curtain closed
- `resource/images/room_108_bed_window.png`: room 108 bed and window angle
- `resource/images/room_108_bathroom_entry.png`: room 108 bathroom entry angle
- `resource/images/room_108_bathroom.png`: room 108 reused bathroom angle
- `resource/images/room_108_bathroom_curtain_closed.png`: room 108 bathroom with the shower curtain closed
- `resource/images/exterior_stairs.png`: exterior stairs
- `resource/images/laundry_room.png`: laundry room with the second washer door open
- `resource/images/laundry_room_washer_closed.png`: laundry room with the second washer door closed
- `deprecated/2026-08-01-legacy-assets/images/`: archived previous image assets, disconnected from scenes
- `resource/sounds/footstep.ogg`: movement footstep sound, repeated quickly during scene transitions
- `resource/sounds/licenses/fantozzi_footsteps_license.txt`: source and license record for the footstep sound

## Resource Organization

- Put photos and other image assets under `resource/images/`.
- Put sound assets under `resource/sounds/`.
- Put sound source/license records under `resource/sounds/licenses/`.
- Keep retired documents, source files, tests, and resources in a date-prefixed directory under top-level `deprecated/`.

## Start

Open this folder in Godot and run the main scene:

- Main scene: `scenes/main.tscn`
- Main script: `scripts/main.gd`

## Add Or Edit Click Areas In Godot

Click areas are now editable in the Godot scene editor.

1. Open `scenes/main.tscn`.
2. In the Scene tree, open `Main > HotspotDefinitions`.
3. The scene groups are laid out in a grid on the 2D canvas, so pan/zoom to the scene you want, such as `front_desk` or `laundry_room`.
4. Select a hotspot child node under that scene group and drag or resize its rectangle in the 2D viewport.
5. Edit its Inspector fields:
   - `hotspot_id`: stable id for localization and saved logic
   - `hotspot_label`: debug label shown when click areas are visible
   - `target_scene_id`: scene id to move to when clicked
   - `description_text`: text shown when clicked
   - `action`: special action such as `toggle_laundry_washer`

Each scene group includes a `PhotoPreview` node so the rectangles can be positioned over the actual photo. `PhotoPreview` is ignored at runtime.

Moving an entire scene group is only an editor organization change. Runtime uses hotspot positions relative to that group, so moving the group around the 2D canvas does not change gameplay. Moving or resizing a hotspot child node does change gameplay.

The legacy code data in `scripts/main.gd` still exists as fallback. Runtime reads editor-authored nodes first; if a scene has no nodes under `HotspotDefinitions/<scene_id>`, it falls back to `HOTEL_SCENES[scene_id]["hotspots"]`.

## Legacy Click Area Data

Most other game setup is still in `scripts/main.gd`.

Each photo scene lives in `HOTEL_SCENES`. A click area is a `hotspots` entry:

```gdscript
{
	"id": "desk_bell",
	"label": "Bell",
	"rect": Rect2(0.407, 0.407, 0.075, 0.095),
	"text": "The bell gives a thin ring that hangs in the lobby for a second.",
}
```

`rect` uses normalized photo coordinates:

- first number: x position from left, `0.0` to `1.0`
- second number: y position from top, `0.0` to `1.0`
- third number: width
- fourth number: height

To move to another scene when clicked, use `target`:

```gdscript
{
	"id": "front_door",
	"label": "Exit Door",
	"rect": Rect2(0.330, 0.020, 0.235, 0.500),
	"target": "corridor",
}
```

## Current Navigation

- Front Desk: click the right edge to move to the Corridor.
- Corridor: click the left edge to return to the Front Desk.
- Corridor: click the bottom edge to move to the Exterior Stairs.
- Corridor: click Room 105, Room 106, Room 107, or Room 108 doors to enter different rooms.
- Exterior Stairs: click the right edge to return to the Corridor.
- Room 105: click the door to return to the Corridor.
- Room 105 or Bathroom Entry: click either edge to turn to the other room angle.
- Room 105 Bathroom Entry: click the bathroom doorway to enter the Room 105 Bathroom.
- Room 105 Bathroom: click the door to return to the Bathroom Entry.
- Room 106: click the bathroom doorway to enter the reused Room 106 Bathroom, or the exit edge to return to the Corridor.
- Room 106 Bathroom: click the door to return to Room 106.
- Room 107: click the right edge to turn to the Bathroom Entry angle, or the visible door to return to the Corridor.
- Room 107 Bathroom Entry: click the bathroom doorway to enter the reused Room 107 Bathroom.
- Room 107 Bathroom: click the door to return to the Bathroom Entry.
- Room 108: click the left edge to return to the Corridor, or the right edge to turn to the Bathroom Entry angle.
- Room 108 Bathroom Entry: click the right bathroom doorway to enter the reused Room 108 Bathroom, or the left edge to turn back.
- Room 108 Bathroom: click the door to return to the Bathroom Entry.
- Front Desk: click the left edge to enter the Laundry Room.
- Laundry Room: click the bottom edge to return to the Front Desk.
- Laundry Room: click the second washer to toggle its door open or closed.

## Audio

- Scene transitions play `resource/sounds/footstep.ogg`.
- The game repeats the single footstep three times at short intervals to imply walking between spaces.
- Sound source records live in `resource/sounds/licenses/`; add one record per external source.
- Current credit text, if credits are later added: `Footstep sound effects based on "Fantozzi's Footsteps (Grass/Sand & Stone)" by Fantozzi, submitted to OpenGameArt by qubodup. Licensed under CC0 1.0 Universal.`

## Inventory And Equipment

- `scripts/items/inventory_model.gd` owns inventory state and the currently equipped item.
- `scripts/items/item_definition.gd` is the item data object used by inventory UI and future pickup logic.
- `scripts/items/item_combination_rule.gd` defines item-to-item drag combination rules.
- `scripts/ui/inventory_screen.gd` builds the Esc inventory panel and the `Hand` drop slot.
- `scripts/ui/inventory_item_button.gd` provides drag data for inventory items and accepts item drops for combination.
- `scripts/ui/equipment_slot.gd` accepts dragged items and equips them through the inventory model.
- `scripts/ui/equipment_hud.gd` shows the currently equipped item in the lower-left square.
- `scripts/ui/rule_book_screen.gd` renders the menu Rule Book panel from localized rule keys.

Current test items are seeded in `scripts/main.gd` so drag-to-hand equipment and item-to-item combination can be verified before pickup gameplay exists.

The retired Room 105 cleanup item and mechanic are preserved under `deprecated/2026-08-01-mold-removal/` and are no longer registered in the live inventory.

## Controls

- `E`: close or open your eyes. Closing your eyes darkens the screen to a thin horizontal slit; VHS noise disappears while the eyes are closed.
- `F`: use the item currently equipped in Hand. When a regular hotspot is under the cursor, the equipped item is applied to that hotspot.
- `Esc`: open the menu. The Controls tab repeats the current shortcuts in game.

The closed-eye view uses an injectable profile in `scripts/systems/eye_close_profile.gd`. Normal, anomalous, and child-song vision radii plus heartbeat, breathing, and humming streams can be replaced independently. Debug builds expose a radius slider beside the other debug controls.

## Progressive Night Rules

Starting a new shift opens directly on the Front Desk photo with gameplay paused. A short story sequence appears at the start of every Day: the unclaimed-wages call and debt on Day 1, the prior employee record and two contacts on Days 2–3, the older sister's identity and investigation on Days 4–5, her warning on Day 6, and the player's recognition on Day 7. The sequence uses a raised, borderless dialogue layer whose black background fades toward the bottom. Text types from the upper-left with short punctuation pauses; clicking while it types reveals the whole line, and clicking again advances. Completed beats and the current step are saved so loading resumes at a safe boundary without replaying finished story.

The Rule Book is split into one page per day. Each page contains only the rules newly issued that day, the latest page opens automatically whenever a day starts, and arrow navigation keeps earlier pages available. Day 1 begins with three ordinary housekeeping rules; later days reveal the open-wardrobe rule, Room 108 phone, Room 109, red washer, and abandoned-child rules. Day 7 ends with three short Room 109 instructions.

Rule Book presentation is image-ready. Drop photographed or scanned handwritten pages into `resource/images/rule_book/` as `day_01.png` through `day_07.png`; the matching image automatically replaces that Day's generated text cards. Locale-specific files such as `resource/images/rule_book/ko/day_01.png` take priority, and missing images fall back to the current localized text UI. See `resource/images/rule_book/README.md` for the complete convention.

The production anomaly runtime allows only one active encounter at a time. Day 4–7 use the fixed main sequence of unanswered call, red washer, unregistered child, and the Room 109 passage; Day 2 onward can also schedule at most one separate production anomaly after conflicts clear. Runtime death, game-over, and jumpscare presentation are enabled.

- The Room 105 wardrobe waits five minutes before opening, then spends four minutes in each of its open-door and emerging-man stages. Global pig squeals recur every 24–42 seconds while active; holding the wardrobe for five seconds pushes the man back and closes it.
- Calls originate from Room 108. The front desk phone must be answered before its thirteenth bell, and an answered light-repair request makes Room 108 unsafe to enter.
- The unresolved Day 3 Room 109 encounter remains debug-only. On Day 7, first entry into the corridor starts the completed wait-and-footsteps passage; touching the door or leaving early is fatal.
- A red washer must be stopped; its door and the laundry-room exit remain dangerous until the completion music finishes. The resulting load is discarded while the player's eyes are closed.
- The Room 106 child encounter starts singing automatically when the player closes their eyes. After the crying stops, the child can be held; fatal branches are connected to the game-over presentation.

## Gameplay Systems Plan

- `docs/gameplay-systems-design.md` defines the planned interaction runner, hotel task system, item-to-hotspot use, rule-book data model, anomaly resolution conditions, and save-state boundaries.
- `docs/anomaly-bible/` is the anomaly bible. It separates complex named **Entities** from small, easily corrected **Phenomena** and keeps one document per approved event.
- `docs/anomaly-bible/candidates.md` keeps promising anomaly concepts separate from approved canon.
- `docs/night-structure.md` defines the story-led seven-night progression and guarantees that only one anomaly can be active at a time.
- New hotel duties and anomaly fixes should follow that plan instead of adding more one-off action branches to `scripts/main.gd`.
- `scripts/interactions/interaction_action_runner.gd` now handles hotspot action execution, including legacy action strings and new dictionary actions.
- `scripts/tasks/task_manager.gd` owns hotel duty state. Current sample duties are Room 105 bedding, Room 105 bathroom sink cleaning, and Room 107 loose paper collection.
- `scripts/systems/flag_store.gd` owns small persistent flags such as the laundry washer door state.
- `scripts/rules/rule_book_manager.gd` gives Rule Book entries stable rule ids and read-state tracking.

## Item Combination

- Drag one inventory item onto another inventory item to attempt a combination.
- Combination rules live in `HotelInventoryModel` as `HotelItemCombinationRule` objects.
- Each rule can consume either source item, consume either target item, and create one or more result items.
- Current sample: `Flashlight + Guest Note` keeps the flashlight, consumes the original note, and creates `Revealed Note`.
- Combination result text uses `combine.<rule_id>` localization keys.

## Dialogue

- `persistent_dialogue`: scene-level dialogue shown near the bottom. It is off by default and stays off across room changes until toggled on.
- `transient_dialogue`: short hotspot feedback shown above `persistent_dialogue`. It is borderless, centered, capped to two lines, fades out automatically, and is hidden while dialogue is off.

## Localization

- `scripts/localization.gd` owns language state and translation lookup.
- Korean is the default language. English is the complete fallback locale.
- Supported language slots are English, Korean, Japanese, Russian, and Chinese.
- Scene, hotspot, exit, UI text, item names/descriptions, rule book text, and scene photo paths are routed through localization keys with the current English text/path as fallback.
- Item text uses `item.<item_id>.name` and `item.<item_id>.description`.
- Localized photo variants can use `scene.<scene_id>.photo`; the closed laundry variant can use `scene.laundry_room.photo.closed`.
- Rule Book entries use `ui.rule_book.rule.<number>` and unlock by their definition's `unlock_day`.

## Debug Controls

The debug controls are visible when running from the Godot editor, or when Godot is launched with `HOTEL_DEBUG_UI=1`.

```sh
HOTEL_DEBUG_UI=1 /Applications/Godot.app/Contents/MacOS/Godot --path .
```

- `▣`: shows or hides click area overlays. The real game view keeps them hidden by default.
- `💬`: shows or hides the bottom chat/message panel. It is off by default.
- `🧭`: shows or hides quick travel buttons. It is off by default and works independently from the chat panel.
- `🛁 Gameplay / Open / Closed A`: while viewing any Room 105-108 bathroom, immediately compares the gameplay state, the original open photo, and the `edit_002` closed photo. Preview choices do not modify or save the real curtain state; retired candidates live only in `deprecated/`.

## Pause Menu

- Press `Esc` to open or close the menu.
- Opening the menu pauses gameplay with `SceneTree.paused`.
- `scripts/systems/playback_pause_manager.gd` also pauses active audio/video players under the gameplay layer so future sounds and videos follow the same pause rule.
- The menu moves to the left side of the overlay; the right side can switch between Inventory/Hand and Rule Book.
- `Rule Book` opens the latest day page by default; arrow buttons browse the earlier daily additions.
- `Continue` returns to the game.
- `Brightness` adjusts the game photo brightness without changing the menu UI.
- `Quit` exits the running Godot game.

## Web Build

The project already uses the GL Compatibility renderer and a scalable canvas setup, which are appropriate for a web export. In Godot, use `Project > Export > Add... > Web`.

Create the same release build used by GitHub Pages:

```sh
tools/export_web.sh
```

Every push to `main` runs the automated tests, creates a single-threaded Web release, and deploys it with GitHub Actions. The published game is available at `https://big-gorae.github.io/hotel-web-01/` after GitHub Pages is configured to use GitHub Actions as its source.

## Test Harness

This project uses a two-layer Godot test harness:

- `GdUnit4 6.1.3` for fast unit tests under `tests/unit/`.
- Headless Godot smoke scripts under `tests/smoke/` for full `scenes/main.tscn` gameplay flow checks.

Run everything locally:

```sh
tools/test_all.sh
```

Run only unit tests:

```sh
tools/run_unit_tests.sh
```

Run only smoke tests:

```sh
tools/run_smoke_tests.sh
```

If Godot is not installed at `/Applications/Godot.app/Contents/MacOS/Godot`, set `GODOT_BIN`:

```sh
GODOT_BIN=/path/to/Godot tools/test_all.sh
```

GdUnit4 reports are written to `reports/`, which is ignored by git.
