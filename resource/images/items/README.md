# Item Icon Assets

The small-mirror icon is a project-bound bitmap asset generated with the built-in ImageGen workflow on 2026-07-25.

## Files

- `small_mirror.png`: ordinary worn handheld mirror
- `hell_mirror.png`: opaque black MVP placeholder for the transformed mirror

Both files are `512 × 512` PNGs. `small_mirror.png` uses transparency. `hell_mirror.png` is intentionally an opaque black square until its final face art is supplied.

## Prompt intent

- Small mirror: one compact oval hotel hand mirror, worn silver rim, dark wooden handle, cloudy glass, grounded semi-realistic inventory art, no magical decoration.
- Hell mirror: no generated face art in the current MVP; black placeholder only.

The inventory model stores an optional `icon_path`. Inventory buttons, drag previews, the HAND slot and the compact equipment HUD load these PNGs; items without a raster icon continue to use `icon_text`.
