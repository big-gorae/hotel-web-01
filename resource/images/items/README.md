# Item Icon Assets

The mirror icons are project-bound bitmap assets generated with the built-in ImageGen workflow.

## Files

- `small_mirror.png`: ordinary worn handheld mirror
- `hell_mirror.png`: final transparent icon of the transformed mirror, with an impossible folded figure trapped in its depth

Both files are `512 × 512` PNGs with transparency. The final `hell_mirror.png` was generated and composited on 2026-08-01.

## Prompt intent

- Small mirror: one compact oval hotel hand mirror, worn silver rim, dark wooden handle, cloudy glass, grounded semi-realistic inventory art, no magical decoration.
- Hell mirror: the same worn handheld object corrupted into a black reflective depth containing one fetal, folded animal-person shape; no rune, glow, gore, or explanatory text.

The inventory model stores an optional `icon_path`. Inventory buttons, drag previews, the HAND slot and the compact equipment HUD load these PNGs; items without a raster icon continue to use `icon_text`.
