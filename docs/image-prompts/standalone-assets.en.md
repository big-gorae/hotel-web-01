# Confirmed Anomaly Standalone-Asset Prompts — English

Baseline: 2026-07-26

These prompts generate isolated assets without supplying or rebuilding the hotel photograph. Each code block is under 800 characters. For entries with `STATE`, generate one state per request and use the accepted first result as the identity reference for later states.

## Shared usage

- People, objects, and stains: transparent PNG; if unsupported, use flat mid-gray with no cast shadow.
- Screens, paintings, and wallpaper: front-facing rectangular textures with no device, frame, or wall.
- Light: glow pass on black for Screen/Add compositing.
- Never generate the hotel room or surrounding furniture.

# A. Phenomena

## P01. Monitor ghost

```text
Front-facing 16:9 texture for a powered-off LCD. In nearly black polarized glass, show the extremely faint reflection of an adult head and shoulders, placed slightly low and off-center. Pores and damp fragments of skin are barely readable; eyes, nose, and closed mouth resolve only on close inspection, while the first glance suggests a reflection stain. Use weak gray static and realistic glass reflections. No glowing eyes, skull, giant mouth, white-robed ghost, or hair hiding the face. Generate only screen content: no monitor bezel, desk, room, full body, text, or UI. Photoreal night texture, restrained contrast.
```

## P02. Face beyond the glass door

```text
STATE=PEEK or HOSTILE. Photoreal cutout of half an adult face designed to appear behind a vertical gap at night. Show part of the forehead, one eye, half the nose, and half the mouth; everything else ends at one clean vertical occlusion line. PEEK has an unblinking stare and a tiny courteous smile held too long. HOSTILE preserves identity, angle, and scale, opening the eye unnaturally wide and pulling the visible mouth corner into a vicious grin. Damp pores, low saturation as if seen through glass. No hand, body, blood, wounds, or glowing eyes. No frame, glass, building, or background; transparent background.
```

## P03. “죽어” sign

```text
Front-facing texture of a worn cream plastic sign bearing the exact Korean characters “죽어” in thick, rough dark-red pigment. It was hurriedly pressed on with fingers or a dry brush, not a digital font: pressure breaks stroke thickness, cracks edges, and creates only very short downward drags. No hand, handprints, flowing blood, English, runes, or other words. Flat perspective, even light, uncropped lettering. If exact Korean text fails, generate a clean aged sign surface plus a separate transparent layer of rough dark-red brush texture for manual typography.
```

## P04. Red room lamp

```text
An isolated small wall-mounted lamp from a worn budget hotel, switched on in deep saturated red. The bulb core is bright red while dust, scratches on the glass cover, and the metal base remain visible. Near-frontal three-quarter angle, photoreal exposure, warm red emission. No global red grade, alarm beacon, flame, smoke, or blood. Do not generate wall, door, room number, or hotel room. Transparent background around the fixture. Its silhouette must also support a separate glow-pass version containing only soft red spill on black for Screen/Add compositing.
```

## P05. Blood puddle beneath a door

```text
Isolated alpha asset of a dark-red liquid puddle whose rear edge begins as a thin seep from beneath an unseen door. The center is viscous, nearly black burgundy; thin edges carry wet red reflections and irregular tongue shapes. It is shallow, motionless, and viewed from a low floor-level angle. No footprints, handprints, corpse, organs, hair, or drag marks. Do not generate a door, wall, floor tile, or room. Transparent background, no cast shadow, neutral restrained highlights so the liquid can be color-matched later.
```

## P06. Baby-face wallpaper

```text
STATE=EYES_OPEN or EYES_CLOSED. Seamless square wallpaper texture on aged yellowed paper, densely repeating dozens of fictional uncanny infant faces: swollen eyelids, tense foreheads, compressed noses, half-open mouths frozen before crying, and varied asymmetry. Never cute or toy-like; resemble an old print copied incorrectly. EYES_CLOSED preserves the accepted face count, layout, scale, mouths, and stains, changing only every eyelid to a forcefully closed state. No real child photograph, injury, blood, body, or text. Perfectly flat, even light, seamless tile.
```

## P07. Human-skin towel

```text
Isolated cutout of one wet fictional sheet of human-like skin folded over an unseen towel rail. The thick heavy gray-beige and blotched pink membrane sags along its central fold with an irregular lower edge. Pores, fine hair, moles, tonal variation, and several coarse stitch marks make it unmistakably unlike cloth. No face, nipple, ear, fingers, limb, tattoo, torso silhouette, or flowing blood. Do not generate the rail, wall, or bathroom. Near-frontal three-quarter view, transparent background, no cast shadow, weak neutral highlights only on damp areas.
```

## P08. Hellbound emergency arrow

```text
Isolated aged emergency direction light with a simple, immediately readable arrow pointing downward. The arrow burns in overexposed scarlet while the old translucent plastic cover and scratched metal case remain visible. No literal hell, flame, lava, demon, hand, person, words, new passage, neon decoration, or fantasy rune. Near-frontal angle, transparent background around the sign. A separate glow pass may contain only scarlet emission spreading weakly from the sign and downward on black.
```

## P09. Grotesque portrait

```text
Vertical aged oil-painting texture for insertion inside a frame. A frontal adult face remains human-readable, but one eye is excessively deep, the other subtly high, and cheek tissue sags in layers. The mouth exceeds plausible jaw limits, exposing too many irregular wet teeth in darkness. The expression is not a victim’s scream but malicious delight at being noticed. Unify it with real brushwork, cracked varnish, and yellowed canvas. No frame, wall, room, hand, insects, flowing blood, or glowing eyes. Flat frontal image, 4:5.
```

## P10. TV ghost

```text
STATE=ACTIVE or HOSTILE. Front-facing 4:3 monochrome CRT screen texture. A pale adult face and upper shoulders look into the camera through coarse static and scanlines. ACTIVE is nearly expressionless, with eyes and closed mouth readable at small size. HOSTILE preserves identity, scale, and position, raises static contrast, opens the eyes too wide, and pulls the mouth corners into a vicious partial-toothed grin. The face never enlarges or exits the image. No TV bezel, furniture, room, cable, or UI. Screen content only, pixel-registered between states.
```

## P11. Legs behind the shower curtain

```text
Isolated cutout of two pale adult legs belonging to an unidentified person lying inside an unseen bathtub. Lower legs and bare feet are clearest; upper thighs terminate naturally toward the rear so the reclining pose reads immediately. Use real gravity, uncomfortable stillness, damp skin, and weak neutral highlights. No standing pose, feet reaching toward camera, face, hand, torso, injury, blood, decay, or identity cue. Do not generate tub, curtain, tile, or bathroom. Transparent background, no cast shadow, crisp limb edges for later occlusion.
```

## P12. Empty noose

```text
Isolated cutout of a thick, worn rope noose with nobody inside. The upper rope continues taut toward an off-canvas ceiling; below it hangs a functional knot and weighty oval loop under gravity. Render coarse fibers, frayed wear, and realistic twist. No person, child, hair, clothing, blood, human-shaped shadow, chair, or scissors. Do not generate ceiling, room, bed, or anchor hardware. Near-frontal three-quarter view, transparent background, no floor shadow, complete uncropped vertical rope.
```

## P13. Red handprint mirror decal

```text
Transparent decal sheet densely packed with dark-red handprints of varied size and pressure. Mix palms, fingertips, sideways smears, old brown-dried layers, and wetter red marks. Add short gravity-directed drops to only a few prints. No physical hands, arms, faces, player reflection, or text. Avoid mechanical repetition. Generate only prints and smears on transparency—no mirror, frame, sink, or bathroom. Front-facing rectangular alpha asset with clear outer margin.
```

## P14. Horrific bathroom in the mirror

```text
Front-facing vertical image for insertion into a mirror reflection. An old tiled bathroom extends into an impossibly deep, endless corridor. Crooked sinks and toilets repeat into distance; grout is wet black, with old hair clumps and dark-red dampness near drains. At the farthest depth, show only several vague human-like forms pressed behind opaque glass or plastic. No clear central face, child, hand, portal rim, rune, or magical glow. Do not generate the real mirror or outside bathroom. Frameless image, deep perspective, 3:4.
```

## P15. Entrails for the bathtub

```text
Isolated cutout of a photoreal fictional entrail mass for filling a bathtub. Gray-pink intestinal coils of varied thickness, dark-maroon tissue, thin membranes, and clotted blood compress and intertwine in dark-red water, forming a broad low oval pile. It must resemble premium horror-film practical prosthetics, never red noodles or glossy plastic. No head, face, eye, hand, foot, complete limb, fetus, or torso. No crawling or living pose. Do not generate tub, curtain, bathroom, or floor. Transparent background, no cast shadow, restrained wet highlights.
```

# B. Entities

## E01. Closet pig-mask man

```text
ASSET=PIG_MASK_MAN_PEEK or PIG_MASK_MAN_FATAL. PIG_MASK_MAN_PEEK is a narrow door-gap fragment of the exact approved pale peach-pink pig mask. Lock its relatively smooth surface, very high rounded forehead, asymmetric ears, tiny low-set recessed circular eye holes, broad short snout, round black nostrils, and tiny mouth. Show part of one ear, one side of the forehead, exactly one complete eye hole with a pale gray human eye, and half of the snout with one full nostril plus only the inner edge of the second nostril; show no second eye, full mask, or body. Do not obscure the design with mud or heavy grime. PIG_MASK_MAN_FATAL is a frontal close-up of the same mask. No forest, black coat, wardrobe, door, room, woman’s face, literal pig head, alternate pig-mask design, or bloody wounds. Transparent background.
```

## E02. Unanswered call

```text
Face asset for a global fatal event. An adult human-like presence of indeterminate sex and era continues laughing from a telephone at the player’s immediate side. One cheek is slightly nearer the lens; the eyes stare frontally without smiling while only the mouth opens into an excessively broad, silent laugh. A small blurred curve of an old black receiver may appear beside one ear. No cord, number, room marking, hotel uniform, specific injury, blood, or glowing eyes. Face fills over 70% of a horizontal frame; background is total darkness, no UI, only small realistic highlights on damp skin.
```

## E03. Red washer

```text
ASSET=DRUM_CONTENTS or FATAL. DRUM_CONTENTS is a frontal circular insert for closed washer glass: dark-red water, tube-like tissue of varied thickness, and folded flesh-like organic laundry slowly turning under pressure, partly blurred by curved wet glass. Not merely red light. FATAL is a frontal close-up of a wet human-like face compressed behind the same glass; eyes, nose, and mouth remain readable while water and rotation marks push skin sideways, and the mouth smiles. No washer body, laundry room, complete limb, or organ outside the glass. Transparent outside the circle.
```

## E04. Unregistered child and false mother

```text
Full-body cutout of the exact false mother in `resource/images/references/entities/room_106_fake_mother/reference_face_01.png`. Preserve her peach-toned skin, long wet black hair, huge pale eyes, heavy black eye sockets, black-painted nose, broad fixed black smile, and the red mark on the right side of her neck. She wears a wet, worn, desaturated patient gown. Her body faces front while only the neck tilts at a subtly wrong angle. No translucency, guiding gesture, held child, corpse, childbirth, umbilical cord, bloody abdomen, or additional wounds. Do not generate bathroom or child. Transparent background, uncropped full body.
```

Use `resource/3d_models/dripping_gaze/dripping_gaze.glb` for the child and its jumpscare; do not generate them.

## E05. Open door of room 109

```text
Frontal face for the entity’s global fatal event. A human-like presence of indeterminate age and sex appears extremely close within total darkness. Black swallows the outer face and ears, but tiny wet reflections in both eyes, a flattened nose, and a closed mouth extending too far at both ends remain instantly readable. No costume or clue suggesting the missing sister, hotel staff, or any known character. No room number, door, corridor, torso, hand, smoke, glowing eye, or blood. Face occupies 70–80% of a horizontal frame; background is unidentifiable black, no UI.
```

Build the open door and interior darkness locally from the existing door sprite and masks.

## E06. Shadow

```text
Fatal face of the previously invisible following entity. Not a black silhouette: it has clearly readable adult human eyes, nose, and mouth. Ash-gray skin reflects almost no light and its outer edges merge into total darkness. Tiny wet highlights sit in both eyes, the nose is subtly flatter than human, and the closed mouth extends too far at both ends like a smile. Intimate distance, as though it made the final copied footstep directly behind the player; face fills 75% of the horizontal frame. No blood, exaggerated teeth, glowing eyes, smoke body, extra shadow, room background, or UI.
```

Its active state has no image; use only duplicated footsteps and door sounds.

## E07. Child under the blanket

```text
ASSET=MOUND or FATAL. MOUND is an old floral blanket raised by a child-sized body curled sideways with knees to chest: small head rise, curved back, and two knee masses connect naturally beneath one fabric sheet, with realistic thickness, seams, folds, and mattress compression. No face, limb, or opening. FATAL is a frontal close-up of a round child-like face emerging from a black gap in the same floral cloth; the eyes have adult awareness and the mouth smiles with hide-and-seek delight. No real injured child, blood, wound, bed, or room. Transparent background.
```

## E08. Hanged wooden girl doll

```text
A girl-shaped wooden doll in a worn dress. Her face, neck, arms, and legs are unmistakably old wood with visible grain, chipped paint, joined articulation, and shallow cracks rather than human skin. She hangs vertically from a taut noose with her feet off the floor and arms limp, looking directly forward with a bright but unpleasant smile. No blood, neck wound, real-child skin, or arms wrapping around the screen.
```
