# Hotel Web 01

Godot 4 GDScript starter for a 2.5D photo-based point-and-click hotel game.

## Files

- `resource/front_desk.png`: hotel front desk
- `resource/corridor.png`: outside corridor
- `resource/room_105_door_window.png`: room 105 door and window angle
- `resource/room_105_bathroom_entry.png`: room 105 bathroom entry angle
- `resource/room_105_bathroom.png`: room 105 bathroom
- `resource/room_106_bed_window.png`: room 106 bed and window angle
- `resource/room_107_bed_nightstand.png`: room 107 bed and nightstand angle
- `resource/exterior_stairs.png`: exterior stairs
- `resource/laundry_room.png`: laundry room

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
- Corridor: click Room 105, Room 106, or Room 107 doors to enter different rooms.
- Exterior Stairs: click the right edge to return to the Corridor.
- Room 105: click the door to return to the Corridor.
- Room 105 or Bathroom Entry: click either edge to turn to the other room angle.
- Room 105 Bathroom Entry: click the bathroom doorway to enter the Room 105 Bathroom.
- Room 105 Bathroom: click the door to return to the Bathroom Entry.
- Room 106: single room angle for now; click the exit edge to return to the Corridor.
- Room 107: single room angle for now; click the visible door to return to the Corridor.
- Front Desk: click the left edge to enter the Laundry Room.
- Laundry Room: click the bottom edge to return to the Front Desk.

## Test Toggles

- `▣`: click areas are hidden by default for the real game view. Turn this on only when testing hotspot placement.
- `💬`: shows or hides the bottom chat/message panel.
- `🧭`: shows or hides the quick travel buttons inside the chat panel.

## Web Build

The project already uses the GL Compatibility renderer and a scalable canvas setup, which are appropriate for a web export. In Godot, use `Project > Export > Add... > Web`.
