# Rule Book Page Images

Place finished photographed or scanned Rule Book pages in this directory. No code change is required.

## Shared images

- `day_01.png`
- `day_02.png`
- ...
- `day_07.png`

PNG, WebP, JPG, and JPEG are supported. A page image replaces the generated text cards for that Day; if the file is absent or cannot be loaded, the current localized text layout remains as the fallback.

## Language-specific images

Language-specific files take priority over shared files:

- `en/day_01.png`
- `ko/day_01.png`
- `ja/day_01.png`
- `ru/day_01.png`
- `zh/day_01.png`

Keep important handwriting away from the outer edge of the image. The UI preserves the original aspect ratio and fits the whole image inside the page area without cropping.
