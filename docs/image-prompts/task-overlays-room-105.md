# Room 105 일감 레이어 생성 기록

## 제작 방식

- 도구: built-in ImageGen
- 원본: `resource/images/room_105_door_window.png`
- 원본 크기: `1448×1086`
- 결과: full-scene 편집본을 생성한 뒤 변경 영역만 로컬에서 full-canvas alpha PNG로 분리
- SceneLock 정밀 분석은 원본 사진의 외부 전송 승인이 없어 실행하지 않음
- 런타임에서는 이불 1개와 쓰레기 3개를 서로 다른 `task_id`로 관리해 개별 레이어를 독립적으로 제거함

## 어지러운 이불

```text
Use case: precise-object-edit
Asset type: full-scene source for a toggleable hotel housekeeping overlay
Primary request: In the supplied Room 105 photograph, change only the bed so it looks clearly unmade after a guest used it. Pull the floral motel comforter loose and uneven, with a broad diagonal fold, several natural rumples, and one upper corner turned back enough to reveal a modest strip of wrinkled off-white sheet. Shift the existing pillow slightly out of alignment. The result must still look ordinary and mundane, never supernatural.
Input image: the supplied Room 105 photograph is the immutable edit target.
Composition/framing: preserve the exact camera, crop, canvas, bed silhouette, and perspective.
Lighting/mood: exactly inherit the warm bedside lamp from camera-right and the faint cool window fill; match existing dark motel exposure, contact shadows, grain, lens softness, and color cast.
Materials/textures: preserve the original floral fabric pattern, quilting, thickness, and worn texture. Folds must follow the mattress geometry.
Constraints: change only pixels on the visible bed linens and their immediate self-shadow. Keep the headboard, nightstand, lamp, clock, walls, painting, window, curtains, door, chair, desk, carpet, exterior view, and all room geometry unchanged. No people, body-shaped mound, face, limbs, blood, gore, text, watermark, new objects, dramatic lighting, or horror effects. Do not make the bed resemble the child-under-blanket anomaly.
```

## 바닥 쓰레기

```text
Use case: precise-object-edit
Asset type: full-scene source for a toggleable hotel housekeeping trash overlay
Primary request: Add a small, believable cluster of ordinary guest trash to the supplied Room 105 photograph, only on the dark carpet between the desk chair and the foot-left edge of the bed. Include exactly three modest items: one crumpled off-white receipt, one empty plain paper cup lying on its side, and one small clear plastic wrapper. They should look carelessly dropped but not dramatically scattered.
Input image: the supplied Room 105 photograph is the immutable edit target.
Composition/framing: preserve the exact camera, crop, canvas, room geometry, and all existing objects. Keep all trash fully on the visible carpet and separated enough to be individually clickable.
Lighting/mood: exactly inherit the warm bedside lamp from camera-right and faint cool window fill. The trash must be dim, with soft low contact shadows, the same motel grain, exposure, lens softness, and color cast as the original.
Constraints: add only the three trash objects and their tiny contact shadows. Do not change the bed linens, chair, desk, door, window, curtains, walls, painting, lamp, clock, nightstand, carpet texture, exterior view, or any room geometry. No brands, logos, readable text, food, liquid, blood, gore, people, body parts, faces, horror elements, watermark, or extra objects.
```
