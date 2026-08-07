# 호텔 일감 이미지 레이어

일반 호텔 일감은 원본 사진을 교체하지 않고, 원본과 같은 크기의 투명 PNG를 위에 쌓아 표현한다.

## 자산 계약

- 원본 사진은 수정하거나 덮어쓰지 않는다.
- 모든 런타임 레이어는 원본과 정확히 같은 캔버스 크기를 사용한다.
- 레이어 바깥 픽셀은 실제 alpha `0`이어야 한다.
- 오브젝트 좌표는 PNG 안에 이미 포함한다. 런타임에서 별도 확대·이동하지 않는다.
- 정상·정리 완료 상태는 기본적으로 `base_only`다.
- 어지러운 상태나 수거 전 물체만 레이어를 표시한다.
- 쓰레기처럼 하나씩 처리하는 물체는 오브젝트마다 PNG를 분리한다.
- 침대처럼 기존 표면 전체가 바뀌는 물체는 표면 교체 레이어 한 장을 사용한다.
- 일감 레이어는 활성 엔티티·기현상보다 아래에 그린다.
- 사건이 같은 표면을 점유하면 충돌하는 일반 일감 레이어를 숨긴다.

## 권장 레이어 순서

| 범위 | 권장 z-index | 예시 |
| --- | ---: | --- |
| 원본 사진 | 0 | `room_105_door_window.png` |
| 일반 일감 표면 교체 | 10 | 어지러운 이불 |
| 일반 일감 독립 오브젝트 | 20 | 컵, 영수증, 포장지, 수건, 옷 |
| 엔티티·기현상 이미지 | 100 이상 | 이불 속 아이, 피 웅덩이, 손자국 |
| 진행 바와 게임 UI | 이미지 레이어 위 | 홀드 진행도, 명부 |

## Room 105 프로토타입

원본: `res://resource/images/room_105_door_window.png` (`1448×1086`)

| 슬롯 | 파일 | 표시 조건 | 숨김 조건 |
| --- | --- | --- | --- |
| `bedding_unmade` | `bedding_unmade_v2.png` | 이불 정리 `pending` | 이불 정리 완료 또는 이불 속 아이 활성 |
| `trash_cup` | `trash_cup_v1.png` | 컵 미수거 | 컵 수거 완료 |
| `trash_receipt` | `trash_receipt_v1.png` | 영수증 미수거 | 영수증 수거 완료 |
| `trash_wrapper` | `trash_wrapper_v1.png` | 포장지 미수거 | 포장지 수거 완료 |

검수용 합성본과 생성 중간물은 `tmp/imagegen/task_overlays/`에 두며 런타임에서 참조하지 않는다.

## 다음 제작 슬롯

```text
resource/images/tasks/
  room_105_door_window/
    bedding_unmade_v2.png
    trash_cup_v1.png
    trash_receipt_v1.png
    trash_wrapper_v1.png
  room_106_bed_bathroom_entry/
    trash_<object>_v1.png
    wall_blood_stain_v1.png
  room_106_bathroom/
    towels_loose_dirty_v1.png
    towels_folded_clean_v1.png
  room_107_bathroom_entry/
    closet_clothes_v1.png
  room_107_bathroom/
    towels_loose_dirty_v1.png
    towels_folded_clean_v1.png
  room_108_bed_window/
    bedding_unmade_v1.png
    trash_<object>_v1.png
  room_108_bathroom/
    towels_loose_dirty_v1.png
    towels_folded_clean_v1.png
  laundry_room/
    dirty_towel_load_v1.png
    clean_towel_load_v1.png
```

욕실의 일반 수건은 수건걸이가 아니라 바닥·선반의 별도 수건 뭉치로 제작한다. 세탁실의 일반 수건은 붉은 세탁기가 아닌 별도 일반 세탁기와 작업대에만 표시한다.

## 런타임 구현

- `scripts/ui/task_visual_overlay.gd`가 scene별 manifest를 읽어 원본 사진 위에 pending 레이어만 쌓는다.
- 일감 하나가 완료되면 해당 `task_id`의 레이어만 즉시 제거한다.
- manifest의 `suppressed_by_event_ids`에 현재 장면의 활성 사건이 포함되면 충돌 레이어를 숨긴다.
- 이불 정리는 1.4초, 개별 쓰레기는 0.75초 홀드로 처리한다.
- 일반 일감 홀드 링은 초록색이고, 기존 엔티티·기현상 홀드 링은 빨간색을 유지한다.
