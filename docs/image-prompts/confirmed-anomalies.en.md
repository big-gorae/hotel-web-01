# Confirmed Anomaly Image-Generation Prompts — English Production Set

Baseline date: 2026-07-26

This document contains final-production image prompts for the **15 confirmed phenomena**, **8 confirmed entities**, and the mirror items directly required by them. It does not authorize image generation yet. Review and revise the Korean document first, then apply the same revisions to matching IDs in this English set.

## How to use this document

- `Canon confirmed`: the appearance or presentation has already been approved.
- `Art-direction proposal`: a detail that has not become canon yet, such as an entity’s exact face, but has been made concrete enough to generate and review.
- For each asset, concatenate the `Shared scene-edit master prompt` with that asset’s `Asset-specific prompt`.
- Do not regenerate later states from scratch. Supply both the source and the accepted first state as references so identity, object placement, lens, and pixel registration remain fixed.
- A `jumpscare` is a separate full-screen asset, not a scene composite. Append the `Jumpscare master prompt` for any asset that requires one.

## Shared scene-edit master prompt

```text
You are a world-class horror-film production designer and image compositor specializing in photoreal practical effects and restrained psychological horror. The provided SOURCE_IMAGE is the canonical background photograph for this game and is the absolute spatial reference. This is not a request to redesign or repaint the scene. Precisely composite one—and only one—specified anomaly into the designated area of the existing photograph.

Preserve the original camera position, field of view, perspective, crop, pixel dimensions, walls, floor, ceiling, doors, windows, furniture, fixtures, props, exposure, white balance, and shadow direction at pixel-level accuracy. Modify only the region explicitly authorized by the asset prompt. Keep every other pixel as close to the source as technically possible. Do not enlarge or redesign the room, move objects, add entrances, or introduce any unrequested person, face, hand, shadow, writing, blood, or fog.

The result must look like a photograph captured at night inside a real, worn, low-budget hotel. Every inserted element must inherit the source illumination’s exact color temperature and intensity, with physically correct contact shadows, reflections, occlusion, depth of field, and sensor noise. Horror must come from convincing material reality and subtly incorrect humanity, not flashy fantasy effects. Avoid cheap Halloween props, gothic decoration, magic circles, runes, excessive fog, blue moonlight, movie-poster color grading, heavy vignettes, and generative-image warping or melting in the untouched background.

Do not add game UI, cursors, progress indicators, subtitles, watermarks, borders, or letterboxing. The game applies its VHS effect at runtime, so do not bake strong VHS scanlines or global glitches into the scene. Static inside a monitor or TV is allowed only when the asset prompt explicitly requires it. Output at exactly the same canvas size as SOURCE_IMAGE. Return a fully registered full-scene image whose camera and background do not shift when states are swapped.
```

## Jumpscare master prompt

```text
This is a single-frame, face-centered jumpscare asset that fills the screen during a global fatal event. Keep the background dark, shallow, and unidentifiable. If an accepted encounter image exists for this entity, preserve that exact facial identity, hair, skin, and costume cues. Show the face frontally or almost frontally, occupying 65–85% of the frame, with eyes, nose, and mouth immediately readable. Create fear through a recognizably human face with subtly wrong proportions and a malicious expression; do not replace it with an abstract black blot or a generic skull.

Do not use arms wrapping around the screen, hands grabbing the lens, blood splashing on the camera, large text, speed lines, cartoon distortion, or excessive motion blur. The key facial silhouette must remain legible on a small screen and during a very brief display, but do not light the whole face evenly. Retain only realistic small highlights in the eyes and damp skin. Output one 1536×1024 horizontal image with no UI.
```

## Cross-state continuity rule

```text
When generating STATE B or any later state, provide both SOURCE_IMAGE and the accepted previous state as references. Lock the camera, background, subject identity, individual hair strands, facial structure, costume, object silhouette, and object position. Perform only the change explicitly named in the state description. Never allow the subject’s age, sex, face, clothing, pose, or distance from the camera to drift between states. Every state must be perfectly registered so the images can be swapped without any background-pixel jump or alpha blending.
```

# A. Fifteen phenomena

## P01. Ghost figure on the monitor

- Event ID: `front_monitor_ghost`
- Source: `resource/images/front_desk.png`
- Deliverable: `active`
- Status: The figure’s location and behavior are canon confirmed. Its exact face is an art-direction proposal.

```text
Edit only the screen of the large office LCD monitor on the right side of the front-desk photograph. Replace the bright work interface with nearly black glass that appears powered off. Inside that black panel, reveal the faint upper-body reflection of an adult human figure. It must not glow like a video image. It should look as though something is physically standing in a dark space behind the player and is barely reflected in the powered-off panel. The head and both shoulders must be readable, while polarization, weak static, and dark glass prevent the face from resolving immediately. Keep the face away from the screen surface and place the figure slightly low and off-center, as if it were an incidental reflection noticed too late.

Preserve the monitor bezel, stand, keyboard, desk, and entire room. Do not place a matching person or shadow outside the monitor. Do not use glowing eyes, a giant monster mouth, a generic long-haired ghost completely hiding its face, a skull, or a black rectangle. The figure is motionless and must not imply eye tracking or emergence from the screen. At gameplay size the upper body must remain detectable, but its density should allow a first glance to mistake it for a reflection.
```

## P02. Face peeking past the glass door

- Event ID: `front_glass_face`
- Source: `resource/images/front_desk.png`
- Deliverables: `peek`, `hostile`
- Status: The fixed placement and two expression states are canon confirmed. Facial identity is an art-direction proposal.

```text
Outside the central glass entrance, place exactly half of an adult human face peeking from behind the designated vertical doorframe. If no mask is supplied, use the glass door’s viewer-left vertical frame. Show only part of the forehead, one eye, half the nose, and half the mouth; the rest must remain occluded beyond the frame. This is not a decal on the glass or a floating face inside the lobby. The person is physically standing in the exterior night walkway. Accurately apply the existing glass reflections, exterior parking-lot light, frame occlusion, and the slight color shift produced by looking through glass.

In PEEK, the visible eye stares straight inside as though it never blinks. The mouth is closed, with a tiny, falsely courteous smile held too rigidly. In HOSTILE, keep the exact same identity, position, exposure, and occlusion without moving a pixel. Change only the expression: the visible eye opens unnaturally wider, and the visible mouth corner pulls upward beyond comfortable anatomy into a vicious smile. The face must not move closer or reveal more of itself in the second state.

Do not alter the door, bell, monitor, desk, or exterior background. Do not make the face look like a wiped smear. Add no hands, full body, second face, glowing eyes, blood, or wounds. The horror must come from the fact that the identical stationary face changed only its expression in response to the bell.
```

## P03. “죽어” sign

- Event ID: `front_die_sign`
- Source: `resource/images/front_desk.png`
- Deliverable: `active`
- Status: Canon confirmed. Manual compositing is preferred for exact Korean lettering.

```text
Edit only the surface of the checkout sign at the lower left of the front desk. Remove the normal wording and replace it with the exact two Korean characters “죽어,” made with thick, rough red pigment as if a person repeatedly pressed a finger or dry brush against the surface in a hurry. The strokes must not look like a smooth digital font. Their thickness should break with pressure, edges should crack, and a small amount of pigment may drag downward over a very short distance. The lettering must follow the sign’s camera perspective and worn material; it must not cross the sign’s border or glow in midair.

Preserve the sign’s dimensions, angle, frame, and the surrounding phone, bell, and desk. Do not repeat the writing on papers or walls. Add no writing hand, writing animation, handprints, runes, or English text. If the model cannot reproduce “죽어” exactly, generate only the rough red-pigment surface treatment while preserving clean perspective so the final characters can be composited manually in 2D.
```

## P04. Red guest-room light

- Event ID: `corridor_red_room_light`
- Source: `resource/images/corridor.png`
- Deliverable: one `active` state fixed at Room 105
- Status: Canon confirmed.

```text
Change only the wall lamp beside the Room 105 number to a deep, saturated red. The bulb and glass housing must emit light like a real red lamp, with physically plausible falloff across the nearby aged wall, doorframe, door surface, and floor beneath the door. The core may clip into an overexposed red center, but it must not erase all wall texture or the room number.

Preserve the warm-white color of every other room lamp, the distant corridor lights, night sky, and global exposure. Do not apply a red grade to the whole image or invent additional light sources beneath other doors or railings. Add no flame, alarm beacon, blood, human shadow, or smoke. The affected room must be immediately identifiable at a distance while remaining integrated as one real, malfunctioning fixture in the existing space.
```

## P05. Blood puddle beneath a door

- Event ID: `corridor_blood_puddle`
- Source: `resource/images/corridor.png`
- Deliverable: one `active` state fixed beneath Room 105
- Status: Canon confirmed.

```text
Show dark-red viscous liquid seeping from the narrow gap beneath the closed Room 105 door and forming a shallow, irregular puddle on the corridor floor. The thickest accumulation must sit directly at the threshold. Thin tongue-shaped edges should spread sideways and forward along the floor’s subtle slope and seams. Render the center as nearly black burgundy and the thin edges as wet red reflecting the existing wall lamps. The liquid must connect exactly to the under-door gap, implying that its source remains inside the room.

Keep the puddle shallow and motionless. It must not flood the corridor or drip through the railing. Do not open the door or reveal the room interior. Add no footprints, handprints, corpse, organs, hair, or drag marks. Preserve all other guest-room doors and existing floor reflections. The puddle must be discoverable at gameplay scale without becoming a flat patch of oversaturated red paint.
```

## P06. Wallpaper of distressed baby faces

- Event ID: `laundry_baby_face_surfaces`
- Source: `resource/images/laundry_room.png`
- Deliverables: `eyes_open` and `eyes_closed` for each of `floor/ceiling/left/front/right`
- Status: The five surfaces and eye states are canon confirmed. Fine facial art direction is proposed.

```text
Create five independently replaceable, perspective-registered layers for the laundry room’s floor, ceiling, left wall, front wall, and right wall. On each surface, cover the existing material with aged wallpaper or surface printing densely repeated with dozens of distressed baby faces. The faces must not be cute or toy-like. They should resemble uncannily copied human infant faces with swollen eyelids, over-tight foreheads, compressed noses, half-open mouths frozen before a cry, and slightly different asymmetries. Avoid explicit injury or photographs of real harmed children; the horror should resemble human faces reproduced incorrectly in an old printed pattern.

In EYES_OPEN, the faces remain front-facing prints on their respective planes rather than all rotating perfectly toward the camera, yet their open eyes should make the player feel watched from every side. EYES_CLOSED must preserve the exact count, arrangement, scale, mouth shapes, wrinkles, and stains of the corresponding surface. Change only every eyelid on that surface to a simultaneously closed state. The closed faces must not look peaceful; retain tension in the lids and the near-crying expressions.

Keep the washers, open washer door, cart, worktable, chair, detergent, sinks, window, posted notices, and fluorescent fixture unchanged in the foreground. The face pattern must occlude correctly behind every fixture. Do not place faces on appliances, glass, washer drums, or as free-standing human-sized heads. All five planes must align at their seams when active together, and toggling one plane must not alter a pixel on any other plane.
```

## P07. Human skin hanging in place of a towel

- Event ID: `room_107_human_skin_towel`
- Source: `resource/images/room_107_bathroom.png`
- Deliverable: `active`
- Status: Canon confirmed.

```text
Replace only the original towel on the bathroom’s right-side towel rail with a single thick, irregular sheet that unmistakably resembles wet human skin. It is folded neatly over the rail like a towel, but its lower edge is subtly asymmetric and sags under realistic weight. In nearer areas show pores, fine body hair, small moles, skin-tone variation, and several coarse stitch marks so it is immediately clear this is not fabric. Mix pale gray-beige with blotched pink coloration, allowing only the damp areas to reflect the bathroom’s warm light.

Do not form a face, nipple, fingers, ear, complete limb, identifiable tattoo, or torso silhouette. Do not pour blood from the skin or trail it across the floor. Preserve the towel rail, wall, shower curtain, toilet, and sink. The sheet must hang motionless like a heavy object, not move alive or reach toward the player.
```

## P08. Emergency arrow pointing toward hell

- Event ID: `stairs_hell_arrow`
- Source: `resource/images/exterior_stairs.png`
- Deliverable: `active`
- Status: Canon confirmed.

```text
Add an intensely red emergency direction light and downward-pointing arrow to the exterior stair structure, installed as if it physically belongs there. The arrow must not point toward the viewer or upward; it must clearly direct movement farther down the stairs into unseen space. Let the sign’s center blow out into saturated scarlet while realistic red spill reflects onto the nearest metal railing, concrete wall, wet pavement, and underside of the stairs. Preserve the original space at the bottom of the stairs, but make its terminal depth appear blocked by a dense blackness that absorbs the red light and suggests a descent that should not be taken.

Do not alter the building structure, number of steps, railings, parking lot, existing white lamps, or night sky. Do not show literal hell, fire, lava, people, hands, demons, a new door, or a new passage. Do not tint the full scene red; red influence must remain optically plausible around the emergency sign. The horror comes from an ordinary safety marker giving an unmistakably wrong instruction.
```

## P09. Painting of a grotesque face

- Event ID: `room_105_grotesque_portrait`
- Source: `resource/images/room_105_bathroom_entry.png`
- Deliverable: `active`
- Status: A static face inside the frame is canon confirmed. Facial details are proposed.

```text
Preserve the existing frame and glazing on the wall left of the bed, but replace only the landscape inside it with an aged human portrait. The painted face looks forward and remains recognizably human, yet its structure is severely wrong. One eye sits excessively deep while the other is subtly too high. Skin and cheek tissue sag downward in multiple layers. The mouth opens both vertically and horizontally beyond the jaw’s plausible limits, revealing too many irregular wet teeth in darkness. This is not a victim screaming in pain; the expression should be a malicious smile belonging to something delighted that the viewer noticed it.

This must remain an old, cracked oil painting rather than a photograph of a trapped person. Brushwork, cracked varnish, and yellowed canvas texture must unify the whole face. Add no moving-eye implication, flesh leaving the frame, hands, blood, or insects. Preserve the frame position and dimensions, room lighting, bed, lamp, bathroom entrance, and TV. Organize contrast so the face and overextended mouth remain readable from gameplay distance without making the painting glow.
```

## P10. Ghost figure reflected in the TV

- Event ID: `room_108_tv_ghost`
- Source: `resource/images/room_105_bathroom_entry.png`
- Deliverables: `active`, `hostile`
- Status: The low TV placement and two expression states are canon confirmed. Facial identity is proposed.

```text
Edit only the display inside the low CRT television on the dresser at the right of the room. Preserve the TV’s exact size, position, angle, bezel, and every other part of the room. In ACTIVE, show a pale adult face and upper shoulders frontally inside monochrome static. Use simple, high-contrast structure so both eyes and the closed mouth remain readable on the small screen, while no matching person exists in the room outside the TV. The face is nearly expressionless but looks directly at the player. Blend it into low resolution and CRT scan texture as if it emerged from within a dead television rather than from a normal broadcast.

For HOSTILE, use the accepted ACTIVE image and lock identity, scale, position, and head angle. Increase static contrast and electrical noise, open the eyelids unnaturally wide, and pull both mouth corners upward into a vicious smile that reveals part of the teeth. The face must not move toward the camera, enlarge, or cross the TV bezel. Use limited emphasis in the sclera, mouth darkness, and tooth highlights so the expression change remains legible on a small display.

Do not spread glitches, faces, red light, or shadows beyond the screen. Add no plug, power button, or new cable. Runtime controls the flicker, so both still images must remain perfectly registered.
```

## P11. Closed shower curtain and hidden legs

- Event ID: `bathroom_shower_legs`
- Sources: each `room_10X_bathroom.png` and its closed-curtain photograph
- Deliverables: `closed`, `open_empty`, `open_legs`
- Status: Canon confirmed.

```text
Use each bathroom’s existing closed-curtain photograph unchanged for CLOSED. Use the original open, empty tub photograph unchanged for OPEN_EMPTY. For the generated OPEN_LEGS state, add only two pale adult legs inside the tub behind the opened curtain, as if an unidentified adult is lying there. Keep the lower legs and feet most visible. Naturally occlude the upper thighs and torso behind the tub geometry, remaining curtain folds, or the frame edge. Place the legs according to real gravity and tub length, with damp skin taking weak reflections from the bathroom’s warm light and tiles.

Add no injuries, blood, decay, exaggerated body hair, or identity cues. Show no face, hands, torso, second person, reflection, or limbs extending outside the tub. The pose must immediately read as the lower body of someone lying down, not legs standing toward the camera or rising from the tub. Preserve pixel registration for the curtain, tub, tile, toilet, towels, sink, and door. Reuse the same OPEN_LEGS state for the required 3–5 repetitions, then return to the original OPEN_EMPTY image.
```

## P12. Empty hanging rope

- Event ID: `room_107_empty_hanging_rope`
- Source: `resource/images/room_107_bed_nightstand.png`
- Deliverable: `active`
- Status: Canon confirmed.

```text
Add a thick, worn rope physically anchored to the ceiling above the bed in room 107, ending in an empty noose with no person inside it. Render the knot, rope twist, vertical tension under gravity, and a small shadow at the ceiling anchor realistically. The noose should be large enough to notice immediately upon entering, but not exaggerated into the foreground. On the floor or beside the bed below it, place one worn chair appropriate to the room lying on its side, with correct perspective and contact shadows.

The rope must contain no person, child, hair, clothing fragment, or human-shaped shadow. Add no blood, footprints, wall writing, or new lighting. Do not move the bed, window, curtains, painting, lamp, bedside table, or existing floor objects. Do not depict a large swing in the still image; reserve the subtle sway and rope-friction sound for runtime.
```

## P13. Mirror packed with red handprints

- Event ID: `room_105_bloody_handprint_mirror`
- Source: `resource/images/room_105_bathroom.png`
- Deliverable: `active`
- Status: Canon confirmed.

```text
Cover only the glass surface of the left mirror in room 105’s bathroom with dense dark-red handprints of varied scale and pressure, leaving almost no clean space. Mix palm centers, fingertips, sideways smears, and overlapping impressions. Layer several wetter red prints over older brown-dried ones. Allow short drops to run downward from a few marks under gravity, but never cross the lower mirror frame onto the sink or floor.

All marks must sit on the mirror’s dusty reflective surface and never touch the adjacent wall tile, towels, or basin. Add no physical hands, arms, face, player reflection, or separate ghost. Avoid mechanically repeating identical prints; vary size and orientation as if many desperate impressions were made. Preserve the mirror edge, existing light reflections, and the rest of the bathroom.
```

## P14. Mirror showing a horrific bathroom

- Event ID: `room_106_horrific_mirror`
- Source: `resource/images/room_106_bathroom.png`
- Deliverable: `active`
- Status: The alternate bathroom inside the mirror and the transfer mechanic are canon confirmed. The reflected art direction is proposed.

```text
Preserve the real room 106 bathroom in a completely normal state. Alter only the reflection area of the large mirror on the left so it reveals a different bathroom. Instead of reflecting the current layout, the mirror contains an impossible space extending into a much deeper corridor of old tiles with no visible end. Repeated sinks and toilets sit at subtly wrong angles. Tile grout is wet and black, dark-red dampness stains surfaces, and old clumps of hair lie motionless around drains. At the farthest depth, a few vague human-like forms appear pressed behind opaque glass or plastic, but place no clear central face and no child.

Preserve the mirror’s edge, grime, and existing surface gloss while giving the horrific room credible depth behind the glass. Outside the mirror, the real sink, real shower curtain, toilet, towels, tiles, and lighting must have no contamination, blood, or shadow change. Add no portal border, glowing magic, runes, or hands emerging through the glass. Keep the reflection boundary exact so using the small mirror can replace this entire reflected state instantly with the original normal mirror.
```

## P15. Bathtub filled with entrails

- Event ID: `room_108_entrails_bathtub`
- Source: `resource/images/room_108_bathroom.png`
- Deliverable: `active`
- Status: The full-tub appearance and its resolution by holding the whole tub for 4.2 seconds before it drains are canon confirmed.

```text
Fill the interior of room 108’s bathtub with dark-red water and a large mass of intertwined, photoreal fictional entrails. Do not render cheap red noodles or one repeated tube. Create premium practical-effects material with pale gray-pink intestinal coils of varied thickness, dark maroon tissue masses, thin membranes, clotted blood, and clearly submerged portions. Some material should pile just below the rim, compressed and folded under its own weight. Small wet highlights and the viscous dark-red liquid must respond exactly to the bathroom’s existing light. At first glance, the impossible quantity and complicated organic material must read immediately.

Do not include a human head, face, eyes, hands, feet, complete limbs, fetus, or identifiable torso. Do not imply that the entrails are alive, crawling, or sliding out of the tub. Permit only a tightly limited wet trace directly below the tub; do not flood the bathroom with blood. Preserve the tub rim, shower curtain, tile, toilet, sink, towels, and door. The result must resemble top-tier physical prosthetics built for a horror film, never a cartoon, game render, or glossy plastic.
```

# B. Eight entities

## E01. The Closet Pig-Mask Man

- Canon entity name: `Closet Pig-Mask Man`
- Event ID: `room_105_closet_pig_man`
- Source: `resource/images/room_105_bathroom_entry.png`
- Deliverables: man `stage_1`, `stage_2`, `fatal`
- Status: The opening door and pig-mask man are canon confirmed.
- Identity reference: `resource/images/references/entities/room_105_closet_pig_mask_man/reference_pig_mask_01.png`

```text
[STAGE_1]
Lock the entire original Room 105 scene and leave only a narrow black gap in the nearly closed wardrobe. Deep in the darkness, an adult man wearing the exact pale peach-pink pig mask from the identity reference stares at the player. Reveal part of one ear, one side of the forehead, exactly one complete eye hole with a pale gray human eye, and half of the snout. Do not reveal the second eye, full mask, neck, or body. He does not hold the door or step into the room.

[STAGE_2]
Keep the accepted STAGE_1 room, camera, furniture, lighting, perspective, and film grain locked, and open only the wardrobe door moderately wider. The same man remains motionless in the same position and stares directly at the player through both eyes. Both eyes, the full snout, and most of the mask must be readable, while the neck, shoulders, and body remain completely swallowed by the black wardrobe. Preserve the high rounded forehead, asymmetric ears, small recessed circular eye holes, broad short snout, round nostrils, and tiny mouth. Add no forest background, black coat, female face, literal pig head, alternate mask, blood, wounds, glow, or theatrical effects.

[FATAL]
Append the jumpscare master prompt and reveal the exact same pale peach-pink pig mask from STAGE_2 frontally. Preserve the reference's high rounded forehead, asymmetric ears, tiny recessed circular eye holes, broad short snout, round black nostrils, and tiny mouth. Pale gray human eyes inside the holes stare with excessive clarity. Keep the wardrobe, room, and lower body almost invisible, with no sexual exposure.
```

## E02. The Unanswered Call

- Event ID: `room_108_light_repair_call`
- Source: no normal-state scene image
- Deliverable: only `fatal` can be generated
- Status: The event is canonically audio-led. Caller facial identity is proposed.

```text
Create no new normal-state image and no telephone-cord effect. The front-desk phone, rooms, and corridor remain the normal photographs; only the ringing, receiver pickup, and laughter reveal the event.

[FATAL — ART-DIRECTION PROPOSAL]
Append the jumpscare master prompt. Show an adult human-like face of indeterminate sex and era at the player’s immediate side, continuing the laughter heard through the receiver. The face is nearly frontal, but one cheek sits slightly closer to the lens and creates mild asymmetry. A small, out-of-focus curve of an old black telephone receiver may appear beside one ear. The eyes do not smile and look directly into the camera, while only the mouth opens into an excessively broad, silent laugh. Do not place telephone wires, numbers, or room markings in the skin. Because the caller’s identity is unresolved, add no hotel uniform, specific age, cause of injury, or clue linking it visually to room 108.
```

## E03. The Red Washer

- Event ID: `laundry_red_washer`
- Source: `resource/images/laundry_room_washer_closed.png`
- Deliverables: `red`, `fatal`
- Status: The closed washer, organic red contents, and blood beneath it follow the latest confirmed direction. The fatal face is proposed.

```text
[RED]
Edit only the second front-loading washer in the right-hand row of the laundry room. Its circular door must remain fully closed, in its original position and silhouette. Through the closed convex glass, show more than red illumination: the rotating drum contains heavy, wet, dark-red organic laundry resembling entrails, slowly folding over itself under pressure. Water, curvature, and rotation may blur parts of it, but the material must clearly contain tube-like tissue of varied thickness and folded flesh-like bundles. Deep internal red should reflect only weakly along the glass edge and the immediately adjacent white frame.

A small amount of dark-red liquid leaks from the washer’s lower seam, forming a shallow puddle directly beneath and slightly in front of the machine. Do not open the door, modify the drum or control panel, or alter adjacent washers, sinks, cart, or global room lighting. Do not grade the whole image red. Place no organs or hands on the outside of the glass and do not show a complete face or limb clearly inside.

[FATAL — ART-DIRECTION PROPOSAL]
Append the jumpscare master prompt. Connect it to the same washer by showing a wet human-like face compressed directly behind convex circular glass. Eyes, nose, and mouth remain readable, but water and rotation marks push parts of the skin sideways. The mouth smiles as though it enjoys the washer’s completion melody. Preserve the circular-glass reflection and edge distortion across the face, but do not turn the jumpscare into a wide photograph of the full appliance.
```

## E04. The Unregistered Child and the False Mother

- Event ID: `room_106_abandoned_child`
- Source: `resource/images/room_106_bathroom.png`
- Face reference: `resource/images/references/entities/room_106_fake_mother/reference_face_01.png`
- Deliverable: `fake_mother`; use the existing 3D model for the child and its jumpscare
- Status: The false mother’s existence, location, and facial design are canon confirmed.

```text
Do not generate a replacement child. Use an approved render of `resource/3d_models/dripping_gaze/dripping_gaze.glb`, and do not allow the image model to reinterpret the child’s face or body.

[FAKE_MOTHER — CONFIRMED]
Preserve the architecture of room 106’s bathroom and place the exact adult woman from the face reference in the darker area inside the shower space or directly behind the tub. Keep the central foreground and the child’s interaction area empty. Do not redesign or beautify her peach-toned skin, long wet black hair, huge pale eyes, heavy black eye sockets, black-painted nose, broad fixed black smile, or the red mark on the right side of her neck. She wears a wet, worn, desaturated patient gown. Her body faces the camera while her neck tilts at a subtly incorrect angle. Her fixed face looks directly into the camera as though something were imitating a mother soothing a child.

Do not show the real mother’s corpse, childbirth, a dead infant, umbilical cord, bloody abdomen, or explicit wounds. She must not appear outside the bathroom or hold the child. Do not make her translucent; integrate her as a physical object with correct tile and tub occlusion, contact shadow, and damp reflection. She is not a safe guide and must not gesture instructions. Add no speech bubble or written direction.

[FATAL]
Do not generate a separate new facial design. Render the existing child 3D model close to the camera using only the jumpscare master composition. Preserve the model’s geometry, material, and proportions. Do not use the false mother’s face as the fatal image.
```

## E05. The Open Door of Room 109

- Event ID: `room_109_open_door`
- Source: `resource/images/corridor.png`
- Deliverables: `open`, `fatal`
- Status: The open door and invisible interior are canon confirmed. The interior entity’s fatal face is proposed.

```text
[OPEN]
Open only the door to room 109 along its real hinge direction. Preserve the door leaf’s size, number, material, handle, and corridor perspective. Fill the room beyond it with deep, complete darkness that reflects almost none of the corridor light. This must not look like a flat black rectangle: retain threshold depth, inner frame occlusion, and a short visible wall thickness so a real, deep room is implied. However, show absolutely no person, face, eyes, teeth, hands, silhouette, furniture, or other contents inside. Permit only an abnormal weakening of light on the floor immediately before the door. Do not emit black smoke or tendrils.

Preserve every other guest-room door, lamp, railing, and corridor endpoint. Add no arrow, writing, or new hotspot that invites entry. Do not show the entity’s full body on Day 7; handle its passage behind the player through footsteps and system presentation.

[FATAL — ART-DIRECTION PROPOSAL]
Append the jumpscare master prompt. Reveal a human-like face of indeterminate age and sex extremely close within darkness matching room 109. Its outer contour is swallowed by black, but both eyes, a flattened nose, and an excessively long closed mouth remain clearly readable. Add no visual clue that identifies it as the missing sister or another known character, and no hotel uniform or room number.
```

## E06. The Shadow

- Event ID: `hotel_following_shadow`
- Source: no normal-state scene image
- Deliverable: only `fatal` can be generated
- Status: Complete invisibility before death is canon confirmed. The fatal face is proposed.

```text
During the initial `attached` state, add no person, silhouette, extra shadow, screen distortion, or VHS change. In this state, the entity is detected only when the player’s footsteps, door-opening sounds, and front-desk bell repeat once at the same fixed delay. After the player rapidly rings the bell several times, the `bell_distressed` state may use runtime-only screen flicker, but the still image and scene must continue to show no entity shape or additional shadow.

[FATAL — ART-DIRECTION PROPOSAL]
Append the jumpscare master prompt. Show the instant when the previously invisible presence attached behind the player reveals only its face. It must be a person-like face with clearly readable eyes, nose, and mouth rather than a black silhouette. Its skin is ash-gray and reflects almost no light; the outer edges merge into the background darkness until the boundary disappears. Both eyes contain tiny wet highlights, the nose is slightly flatter than a human nose, and the closed mouth extends too far at both ends so it reads as a smile. Add no blood, exaggerated teeth, glowing white eyes, smoke, or visible torso. The intimacy of something that made the final copied footstep directly behind the player must be palpable.
```

## E07. The Child Under the Blanket

- Event ID: `vacant_room_blanket_child`
- Source: `resource/images/room_108_bed_window.png`
- Deliverables: `mound`, `fatal`
- Status: The curled blanket silhouette is canon confirmed. The fatal face is proposed.

```text
[MOUND]
Transform the existing blanket on room 108’s bed into an unmistakably human-shaped mound the size of a young child curled sideways with knees pulled to the chest beneath it. A small rounded rise for the head, a curved back, and two raised knee masses must connect naturally beneath one continuous blanket. Extend the original floral pattern, seams, thickness, and folds across the mound. The body’s weight should compress the mattress and create deep contact shadows around the rise. It must read as a child rather than an adult, but not as a tiny infant.

Show no face, hair, hand, foot, eye, or opening in the blanket. Do not make the fabric translucent or light the silhouette from within. Preserve pillows, headboard, lamp, window, curtains, chair, and the rest of the room. Keep the mound motionless; laughter and distortion are audio-only. Use the original flat bed as the resolved state without generating a new image.

[FATAL — ART-DIRECTION PROPOSAL]
Append the jumpscare master prompt. After saying “mitsuketa—,” the presence pushes only its face out of a black gap beneath the same blanket directly in front of the lens. The rounded structure resembles a child, but the eyes hold excessively adult awareness. The mouth smiles broadly with the joy of winning hide-and-seek and finding the player. Frame the face with fabric carrying the exact same floral pattern to maintain identity. Do not depict a real injured child, blood, wounds, or tears.
```

## E08. The Hanged Wooden Girl Doll

- Event ID: `room_107_hanging_girl`
- Source: `resource/images/room_107_bed_nightstand.png`
- Identity reference: current accepted `resource/images/anomalies/room_107_hanging_girl/room_107_bed_nightstand/visible.png`
- Deliverables: `hanging`, `hostile_eyes`, `fatal`
- Status: Wooden material, frontal gaze, laughter, black eyes with red pupils, and the face jumpscare are canon confirmed. Keep her unmistakably a wooden girl-shaped doll rather than human skin.

```text
[HANGING]
Keep the accepted MVP face shape and worn dress as identity references, but make the face, neck, arms, and legs unmistakably old wood. Show wood grain, chipped paint, joined articulation, and shallow cracks; show no human skin, complexion, or flesh texture. A taut noose anchored to room 107’s ceiling supports the girl-shaped wooden doll by the neck, and her full body physically hangs above the bed and floor. Her feet remain clearly off the floor, both arms hang beside her, and torso and head stay vertical. She looks exactly forward into the camera with a bright but unpleasant expression. Add no neck wound or blood around the rope.

[HOSTILE_EYES]
Use the accepted HANGING state and change not one pixel of the head, face, hair, dress, torso, limbs, rope, or ceiling anchor. Change only both eyes to light-absorbing black and place a small red pupil at each center. Do not exaggerate the expression or open the mouth.

[FATAL]
Append the jumpscare master prompt and show the same wooden girl doll’s face in a frontal close-up. Preserve the exact wood grain, chipped paint, articulation, and cracks. Eyes, nose, and mouth must read instantly while the face fills most of the frame. Never use long arms wrapping around the screen or hands grabbing the camera.
```

# C. Connected items

## I01. Small Mirror

- Item ID: `small_mirror`
- Deliverable: 512×512 icon with transparent background
- Status: Its function is canon confirmed. Object design is proposed.

```text
Create a photoreal inventory icon of one small handheld mirror photographed from a near-frontal three-quarter angle against a transparent background. It is a palm-sized oval mirror with a thin, blackened brass frame, a short handle, and worn edges from long use. The glass is clean but imperfect, showing only faint dust and a blurred neutral reflection of a room. Add no ghost, face, hand, text, rune, or glow.

Keep the complete object uncropped and centered, with a silhouette that reads immediately in a small inventory slot. Make the background and cast shadow fully transparent, retaining only soft neutral illumination and subtle internal contact shading on the object. Finish with photographic materials, crisp edges, and restrained micro-scratches.
```

## I02. Hell Mirror

- Item ID: `hell_mirror`
- Deliverable: 512×512 icon with transparent background
- Status: It is canonically the contaminated state of the same mirror and dangerous in Hand. Its interior imagery is proposed.

```text
Use the accepted SMALL_MIRROR image as the identity and silhouette reference. Do not change the mirror’s size, oval brass frame, handle, camera angle, or canvas placement by even one pixel. Alter only the glass and nearby metal contamination. The glass no longer reflects normally. It becomes deep black with dark-red degraded silvering, and very faint partial eyes, noses, and open mouths from several people appear compressed together at great depth inside the glass. Do not show one complete face. The visual density should communicate screaming souls only after close inspection. Add several hairline cracks originating inside the glass and dark tarnish seeping into the frame.

Add no magic runes, pentagram, flame, skull ornament, purple ray, or exaggerated red aura. No face may emerge beyond the glass and no hand may grip the frame. Ensure that the black reflective field and pale mouth fragments distinguish it immediately from the normal mirror at small icon size while keeping the silhouette unmistakably the same item. Maintain a transparent background and 512×512 canvas.
```

# D. Unconfirmed art direction to review before generation

The event logic and danger below are confirmed, but this document proposes their exact art direction for the first time. Prioritize these items when reviewing the Korean set.

1. Sex, age, and facial visibility of the monitor ghost
2. Identity and initial smile of the glass-door face
3. Material and intensity of the baby-face wallpaper
4. Exact distortion of the framed portrait
5. Facial identity of the TV ghost
6. Grime level of the closet pig mask and the safe framing of the nude body
7. Fatal face of the Unanswered Call
8. Fatal face of the Red Washer
9. Costume, pose, and expression of the False Mother
10. Fatal face of the presence inside room 109
11. Fatal face of the Shadow
12. Fatal face of the Child Under the Blanket
13. Physical design of the Small Mirror and imagery inside the Hell Mirror

Prompts have not softened canon for assets likely to encounter model restrictions, including the entrails bathtub, human-skin towel, and Hanging Girl. During actual generation, do not ask a model to reinterpret an entire scene at once. Use locked selections and accepted references to produce one registered state at a time.
