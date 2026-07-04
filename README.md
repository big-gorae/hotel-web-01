# Hotel Web 01

Godot 4 GDScript starter for a 2.5D photo-based point-and-click hotel game.

## Files

- `resource/front_desk.png`: hotel front desk
- `resource/corridor.png`: outside corridor
- `resource/room_105_door_window.png`: room 105 door and window angle
- `resource/room_105_bathroom_entry.png`: room 105 bathroom entry angle
- `resource/room_105_bathroom.png`: room 105 bathroom
- `resource/room_106_bed_bathroom_entry.png`: room 106 bed and bathroom entry angle
- `resource/room_106_bathroom.png`: room 106 reused bathroom angle
- `resource/room_107_bed_nightstand.png`: room 107 bed and nightstand angle
- `resource/room_107_bathroom_entry.png`: room 107 bathroom entry angle
- `resource/room_107_bathroom.png`: room 107 reused bathroom angle
- `resource/room_108_bed_window.png`: room 108 bed and window angle
- `resource/room_108_bathroom_entry.png`: room 108 bathroom entry angle
- `resource/room_108_bathroom.png`: room 108 reused bathroom angle
- `resource/exterior_stairs.png`: exterior stairs
- `resource/laundry_room.png`: laundry room
- `resource/prev/prev_room_106_bed_window.png`: archived previous room 106 photo, disconnected from scenes

## Start

Open this folder in Godot and run the main scene:

- Main scene: `scenes/main.tscn`
- Main script: `scripts/main.gd`

## Add Or Edit Click Areas

Most game setup is in `scripts/main.gd`.

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
- `Continue` returns to the game.
- `Brightness` adjusts the game photo brightness without changing the menu UI.
- `Quit` exits the running Godot game.

## Web Build

The project already uses the GL Compatibility renderer and a scalable canvas setup, which are appropriate for a web export. In Godot, use `Project > Export > Add... > Web`.
