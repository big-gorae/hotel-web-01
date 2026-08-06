# Rule Book Page Images

## Active notebook background

`notebook_background.png` is the shared background for generated Rule Book pages. It is the selected spiral-notebook direction from draft 04. Replace this one file to change the notebook artwork without editing code.

Korean and English rule copy remains live localized UI text drawn over the background. Do not bake readable copy into this image.

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

## Day 3 story requirements

The photographed/scanned Day 3 page must preserve this exact order and authorship contrast:

1. Rule 6, printed by management: `109호가 열려 있다면 방에 들어오십시오.` / `If Room 109 is open, come inside.`
2. Rule 9, handwritten by the older sister: `■■번 항목은 거짓말이야.` / `Rule ■■ is a lie.` The hidden number must be covered by blood rather than clean censor blocks in the finished page art.
3. Rule 10, printed by management: `9번 지침은 무시하시오.` / `Ignore instruction 9.`

Keep `들어오십시오` / `come inside` intact. The point of the wording is that it reads as an invitation from inside Room 109, not a neutral instruction to enter it.

## Draft backgrounds

`drafts/` contains text-free visual directions for review. They are not loaded as finished Day pages.

- `rule_book_draft_01_clipboard.png`: yellowed sheet on a dark clipboard
- `rule_book_draft_02_carbon_form.png`: cheap carbon-copy management form
- `rule_book_draft_03_laminated_wall.png`: worn laminated sheet taped to a wall
- `rule_book_draft_04_spiral_notebook.png`: worn spiral-bound shift notebook
- `rule_book_draft_05_clothbound_shift_journal.png`: black clothbound shared shift journal
- `rule_book_draft_06_pocket_memo.png`: improvised pocket memo pad

The editable generation jobs live in `docs/image-prompts/rule-book-drafts.jsonl`. They use `gpt-image-1-mini` at low quality. Keep generated backgrounds free of readable text; after a direction is selected, composite the real localized Korean and English copy separately.
