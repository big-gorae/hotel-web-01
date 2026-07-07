# Hotel Web 01

Godot 4 GDScript starter for a 2.5D photo-based point-and-click hotel game.

## Files

- `resource/images/front_desk.png`: hotel front desk
- `resource/images/corridor.png`: outside corridor
- `resource/images/room_105_door_window.png`: room 105 door and window angle
- `resource/images/room_105_bathroom_entry.png`: room 105 bathroom entry angle
- `resource/images/room_105_bathroom.png`: room 105 bathroom
- `resource/images/room_106_bed_bathroom_entry.png`: room 106 bed and bathroom entry angle
- `resource/images/room_106_bathroom.png`: room 106 reused bathroom angle
- `resource/images/room_107_bed_nightstand.png`: room 107 bed and nightstand angle
- `resource/images/room_107_bathroom_entry.png`: room 107 bathroom entry angle
- `resource/images/room_107_bathroom.png`: room 107 reused bathroom angle
- `resource/images/room_108_bed_window.png`: room 108 bed and window angle
- `resource/images/room_108_bathroom_entry.png`: room 108 bathroom entry angle
- `resource/images/room_108_bathroom.png`: room 108 reused bathroom angle
- `resource/images/exterior_stairs.png`: exterior stairs
- `resource/images/laundry_room.png`: laundry room with the second washer door open
- `resource/images/laundry_room_washer_closed.png`: laundry room with the second washer door closed
- `resource/images/prev/prev_laundry_room.png`: archived previous laundry room photo, disconnected from scenes
- `resource/images/prev/prev_room_106_bed_window.png`: archived previous room 106 photo, disconnected from scenes
- `resource/sounds/footstep.ogg`: movement footstep sound, repeated quickly during scene transitions
- `resource/sounds/licenses/fantozzi_footsteps_license.txt`: source and license record for the footstep sound

## Resource Organization

- Put photos and other image assets under `resource/images/`.
- Put sound assets under `resource/sounds/`.
- Put sound source/license records under `resource/sounds/licenses/`.
- Keep disconnected older image assets under `resource/images/prev/`.

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

## Gameplay Systems Plan

- `docs/gameplay-systems-design.md` defines the planned interaction runner, hotel task system, item-to-hotspot use, rule-book data model, anomaly resolution conditions, and save-state boundaries.
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
- English is the default and current language.
- Supported language slots are English, Korean, Japanese, Russian, and Chinese.
- Scene, hotspot, exit, UI text, item names/descriptions, rule book text, and scene photo paths are routed through localization keys with the current English text/path as fallback.
- Item text uses `item.<item_id>.name` and `item.<item_id>.description`.
- Localized photo variants can use `scene.<scene_id>.photo`; the closed laundry variant can use `scene.laundry_room.photo.closed`.
- Rule Book entries use `ui.rule_book.rule.<number>`.

## Debug Toggles

The three debug toggles are visible when running from the Godot editor, or when Godot is launched with `HOTEL_DEBUG_UI=1`.

```sh
HOTEL_DEBUG_UI=1 /Applications/Godot.app/Contents/MacOS/Godot --path .
```

- `▣`: shows or hides click area overlays. The real game view keeps them hidden by default.
- `💬`: shows or hides the bottom chat/message panel. It is off by default.
- `🧭`: shows or hides quick travel buttons. It is off by default and works independently from the chat panel.

## Pause Menu

- Press `Esc` to open or close the menu.
- Opening the menu pauses gameplay with `SceneTree.paused`.
- `scripts/systems/playback_pause_manager.gd` also pauses active audio/video players under the gameplay layer so future sounds and videos follow the same pause rule.
- The menu moves to the left side of the overlay; the right side can switch between Inventory/Hand and Rule Book.
- `Rule Book` opens a Napolitan-style hotel rules list.
- `Continue` returns to the game.
- `Brightness` adjusts the game photo brightness without changing the menu UI.
- `Quit` exits the running Godot game.

## Web Build

The project already uses the GL Compatibility renderer and a scalable canvas setup, which are appropriate for a web export. In Godot, use `Project > Export > Add... > Web`.
