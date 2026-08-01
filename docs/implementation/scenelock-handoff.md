# SceneLock 자산 인수인계 명세

## 목적

이 문서는 SceneLock MCP로 만든 이미지가 원본 장면을 훼손하거나, 승인되지 않은 후보가 게임에 섞이거나, 나중에 이미지를 바꾸기 위해 게임 코드를 수정하는 일을 막기 위한 계약이다.

SceneLock 구현은 별도 저장소에서 진행 중이다. 이 게임 저장소는 SceneLock의 내부 DB나 임시 작업 폴더를 직접 읽지 않고, 사용자가 **accept**한 결과를 명시적으로 export한 파일과 영수증만 받는다.

## 전제

붙여 넣은 `SceneLock Local Agent MCP Design`의 다음 결정을 그대로 따른다.

- `scenelockd`만 이미지 작업 상태를 쓰는 단일 writer다.
- 분석·편집·합성은 durable async task이며 task ID로 poll한다.
- source, locked selection, candidate와 accepted artifact는 immutable하다.
- mutating tool은 idempotency key를 요구한다.
- provider key는 Keychain에 남고 게임 저장소나 MCP 응답에 들어오지 않는다.
- source 이미지는 덮어쓰지 않는다.
- base64 이미지를 JSON에 넣지 않고 로컬 파일과 안정적인 resource URI를 사용한다.
- 후보 생성과 게임 반영은 별개다. 게임에는 accepted result만 들어온다.

## 저장소 경로 계약

```text
resource/
  images/
    anomalies/<event_id>/<scene_id>/<state>.png
    items/<item_id>.png
    rule_book/<locale>/day_<NN>.png
  sounds/
    anomalies/<event_id>/<cue>.ogg
    licenses/<asset_id>.md
  anomaly_manifests/<event_id>.json

receipts/
  scenelock/<event_id>/<asset_slot>.json
```

- `<event_id>`는 이상현상 바이블과 런타임 정의의 ID를 그대로 사용한다.
- `<scene_id>`는 `HotelSceneCatalog`의 안정적인 ID를 사용한다.
- `<state>`와 `<asset_slot>`은 런타임 handler가 내는 상태·슬롯 이름이다.
- 임시 파일, selection preview와 미승인 candidate는 저장소에 복사하지 않는다.
- 같은 의미의 새 결과를 교체할 때도 source나 기존 receipt를 몰래 덮지 않는다. 새 결과의 hash와 SceneLock provenance를 새 commit에서 함께 갱신한다.

## 자산 유형

### Full-scene variant

- 기본 장면과 픽셀 크기와 종횡비가 완전히 같다.
- 넓은 조명 변화, 원근 변화 또는 구조 변경에만 사용한다.
- SceneLock의 `tone_light` 또는 `structural_edit`가 주 작업이다.
- 문, 가구와 이동 핫스폿의 위치는 바뀌지 않아야 한다.

### Full-canvas transparent overlay

- 기본 장면과 같은 캔버스 크기의 투명 PNG다.
- 실제 내용이 화면 일부에만 있어도 좌표를 자르지 않는다.
- Godot에서는 `position=(0,0)`, 화면 맞춤으로 올린다.
- 얼굴, 피 웅덩이, 손자국, 얼룩과 같은 국소 삽입에 우선 사용한다.

### Insert asset

- 인물, 얼굴, 다리처럼 합성 전에 독립적으로 검수할 필요가 있는 투명 배경 자산이다.
- 그대로 게임에 올리지 않고 SceneLock composite의 입력으로 사용한다.
- 최종 게임 자산은 full-canvas overlay 또는 full-scene variant로 다시 export한다.

### Item icon

- 1:1 투명 PNG다.
- `small_mirror`와 `hell_mirror`는 실루엣만 색으로 바꾸지 않고 표면·오염 상태가 작은 크기에서도 구분돼야 한다.
- 인벤토리 레이아웃과 실제 표시 크기에서 별도로 검수한다.

## 게임 프레젠테이션 매니페스트

각 이벤트는 승인된 이미지 상태를 하나의 JSON으로 연결한다.

```json
{
  "schema_version": 1,
  "event_id": "front_desk_monitor_ghost",
  "source_scene_id": "front_desk",
  "source_path": "res://resource/images/front_desk.png",
  "source_sha256": "64-character-lowercase-sha256",
  "canvas": {
    "width": 1535,
    "height": 1024
  },
  "states": {
    "active": {
      "layers": [
        {
          "slot": "monitor_ghost",
          "path": "res://resource/images/anomalies/front_desk_monitor_ghost/front_desk/active.png",
          "sha256": "64-character-lowercase-sha256",
          "width": 1535,
          "height": 1024,
          "z_index": 20
        }
      ]
    },
    "resolved": {
      "base_only": true
    }
  }
}
```

계약:

- 매니페스트에는 예정 경로나 가짜 hash를 넣지 않는다.
- `source_path`는 현재 장면 catalog의 기본 사진과 일치해야 한다.
- source hash가 바뀌면 기존 합성물은 자동 호환으로 간주하지 않는다. 새 source에서 다시 검증한다.
- full-scene variant와 full-canvas layer는 모두 `canvas` 크기와 일치해야 한다.
- 한 state 안의 layer `slot`은 중복되지 않는다.
- `base_only` state는 artifact와 함께 사용할 수 없다.
- 런타임 shader, VHS, 깜빡임과 wipe 수치는 JSON 이미지 상태가 아니라 이벤트 presentation policy에서 관리한다.

Godot 검증기는 `scripts/horror/anomaly_presentation_manifest.gd`다. 개발 빌드에서는 경로, hash와 이미지 크기가 틀리면 해당 이벤트를 시작하지 않고 명시적인 오류를 낸다. 배포 빌드는 손상된 자산을 억지로 표시하지 않고 기본 장면으로 안전하게 돌아가며 진단 로그를 남긴다.

## SceneLock receipt

게임 자산마다 다음 provenance를 남긴다.

```json
{
  "schema_version": 1,
  "event_id": "front_desk_monitor_ghost",
  "asset_slot": "monitor_ghost",
  "scene_id": "front_desk",
  "operation": "local_edit",
  "job_uri": "scenelock://jobs/job_...",
  "task_id": "tsk_...",
  "source_sha256": "...",
  "selection_id": "sel_...",
  "selection_sha256": "...",
  "run_id": "run_...",
  "candidate_id": "candidate_...",
  "result_sha256": "...",
  "exported_path": "resource/images/anomalies/front_desk_monitor_ghost/front_desk/active.png",
  "accepted_by_user": true
}
```

receipt는 게임 런타임 입력이 아니라 제작 추적 자료다. SceneLock task log 전체나 provider 응답, 비밀키를 복사하지 않는다.

## MCP 작업 절차

1. `scenelock_status`로 daemon, provider와 허용 root를 확인한다.
2. 이미 같은 SHA-256 source를 가진 job이 있으면 재사용하고, 없으면 `import_image_file`로 immutable source를 만든다.
3. 사용자가 잠근 selection이 있으면 재사용한다. 없으면 `propose_image_selection` 또는 `save_image_selection(lock=true)`을 실행하고 preview를 검수한다.
4. `submit_image_edit` 또는 `submit_image_composite`를 새 idempotency key로 한 번만 제출한다.
5. 반환된 task ID를 `get_image_task` 또는 최대 30초의 `await_image_task`로 poll한다. timeout이나 연결 종료를 새 제출 사유로 삼지 않는다.
6. 후보와 verification report를 비교한다. 보호 대상 손상, 얼굴 왜곡, source drift가 있으면 accept하지 않는다.
7. 사용자 의도가 확인된 후보만 `accept_image_result`로 승격한다.
8. export는 덮어쓰기 없는 고유 staging 경로로 먼저 수행한다.
9. 파일 형식, canvas 크기, alpha, SHA-256을 검사한 뒤 저장소 계약 경로로 이동한다.
10. receipt와 presentation manifest를 같은 변경에 추가한다.
11. Godot import가 끝난 뒤 manifest 검증과 해당 이벤트 debug state를 실행한다.

SceneLock MCP가 아직 설치되지 않았거나 daemon이 준비되지 않았으면 1~7단계를 실행한 것처럼 꾸미지 않는다. 그때는 selection 설명, prompt intent와 출력 슬롯까지만 계획하고 실제 job/task/receipt 필드는 비워 둔다.

## 이벤트별 권장 SceneLock 연산

| 변화 | 우선 연산 | 이유 |
| --- | --- | --- |
| 모니터·TV 화면 형상 | `local_edit` | 화면 내부만 바꾸고 프레임 보존 |
| 유리문 얼굴·피 웅덩이·손자국 | `submit_image_composite` | 독립 asset의 위치·반사·원근 통합 |
| 빨간 객실등·붉은 세탁기 | `tone_light` | 광원과 주변 번짐을 함께 변경 |
| 아기 얼굴 벽면 | `structural_edit` | 면 원근과 반복 패턴을 일관되게 변경 |
| 인간 가죽 수건·끔찍한 액자 | `object_variant` | 기존 물체의 위치를 유지한 상태 교체 |
| 지옥행 비상구 | `structural_edit` | 장면 전체 조명과 깊이 변화 |
| 샤워 커튼 속 다리 | `submit_image_composite` | 다리 asset을 욕조 가림과 조명에 통합 |
| 빈 자살 로프 | `submit_image_composite` | 천장 부착과 바닥 관계를 함께 검수 |
| 거울 속 다른 화장실 | `structural_edit` | 실제 욕실은 보호하고 반사 내부만 재구성 |
| 이불 속 아이 | `structural_edit` | 이불 무늬와 부피 변화를 동시에 보존 |
| 옷장의 돼지 가면 남자 | `object_variant` + composite | 옷장문 상태와 돼지 가면 남자 삽입을 분리 |
| 룰북 촬영본 | import 또는 `tone_light` | 실제 종이 질감과 필기를 보존 |

## Prompt intent 원칙

- 편집할 대상과 바뀌지 않아야 할 대상을 함께 적는다.
- “무섭게”만 쓰지 않고 얼굴 노출량, 시선, 표정, 피의 양과 광원 방향을 적는다.
- 사람 전신이 필요하지 않은 사건에는 전신을 생성하지 않는다.
- 호텔의 기존 벽, 가구, 문 번호, 카메라 위치와 렌즈를 바꾸지 않는다.
- 텍스트가 필요한 안내판·룰북은 생성형 모델의 글자 정확도에 의존하지 않는다. 실제 필기나 검수한 텍스트 레이어를 합성한다.
- 점프스케어용 얼굴은 일반 장면 자산과 별도 selection·candidate 묶음으로 만든다.

## 변형과 강도 조절

- 위치 변화는 `event_id`를 복제하지 않고 scene별 layer slot을 추가한다.
- 공포 강도 변화는 `active_low`, `active_mid`, `active_high` 같은 state variant로 관리한다.
- 진행률마다 full image를 새로 만들기보다 mask, alpha, flicker와 audio parameter를 사용한다.
- 얼굴 표정 또는 팔다리 단계처럼 의미가 바뀌는 지점만 별도 accepted artifact를 만든다.
- 새 자산을 A/B 테스트할 때 gameplay state ID는 유지하고 manifest 버전만 바꾼다.
- debug panel에서 event, scene, state와 variant를 직접 선택할 수 있게 해 실제 Day를 반복하지 않고 검수한다.

## 승인 체크리스트

- [ ] source scene ID, path와 SHA-256이 현재 게임 원본과 일치한다.
- [ ] locked selection preview가 의도한 영역만 포함한다.
- [ ] 문·핫스폿·가구 위치가 바뀌지 않았다.
- [ ] full-canvas 자산 크기가 source와 같다.
- [ ] 투명 overlay의 바깥 픽셀이 실제로 투명하다.
- [ ] 얼굴과 손발 수, 거울 반사와 유리 반사가 의도와 맞다.
- [ ] 밝기와 VHS를 적용한 실제 게임 화면에서도 핵심 형상이 읽힌다.
- [ ] 눈 감기 mask 위·아래 layer 순서가 맞다.
- [ ] accepted candidate만 저장소에 들어왔다.
- [ ] receipt와 manifest hash가 실제 파일과 일치한다.
- [ ] normal, active, progress, resolved와 fatal 상태를 debug mode에서 확인했다.
- [ ] 해당 이벤트 종료 후 overlay와 loop audio가 남지 않는다.
