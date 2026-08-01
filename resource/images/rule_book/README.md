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

## Draft backgrounds

`drafts/` contains text-free visual directions for review. They are not loaded as finished Day pages.

- `rule_book_draft_01_clipboard.png`: yellowed sheet on a dark clipboard
- `rule_book_draft_02_carbon_form.png`: cheap carbon-copy management form
- `rule_book_draft_03_laminated_wall.png`: worn laminated sheet taped to a wall

The editable generation jobs live in `docs/image-prompts/rule-book-drafts.jsonl`. They use `gpt-image-1-mini` at low quality. Keep generated backgrounds free of readable text; after a direction is selected, composite the real localized Korean and English copy separately.
