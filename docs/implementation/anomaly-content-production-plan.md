# 확정 이상현상 콘텐츠 제작 계획

## 범위

이 문서는 바이블에서 확정된 외형과 해결법을 실제 제작 단위로 나눈다. 현재 보류된 Day 3의 109호 초기 조우 해결법을 임의로 채우지 않는다.

산출물 종류:

- `Logic`: 사건별 상태 handler와 튜닝값
- `Hotspot`: 기존 대상 재사용 또는 새 대형 핫스폿
- `Visual`: SceneLock 편집·합성 결과와 절차형 효과
- `Audio`: 단서, 진행 피드백, 해결과 사망 cue
- `QA`: 정사와 구현이 일치하는지 증명하는 테스트

## 공통 자산 규칙

- 원본 사진은 수정하지 않는다.
- 국소 변화는 원본과 같은 캔버스 크기의 투명 PNG 오버레이로 만든다.
- 조명·원근·반사가 장면 전체에 미치는 구조 변경만 full-scene variant를 사용한다.
- 진행 중 상태는 가능하면 이미지 수를 늘리지 않고 shader mask, alpha, 깜빡임과 오디오로 표현한다.
- 얼굴 표정처럼 핵심 공포가 달라지는 상태만 별도 이미지로 만든다.
- MVP 제작에서는 상태마다 `candidate_count=1`만 요청한다. 비교용 대안 후보와 자동 품질 수정 재생성은 만들지 않는다.
- 유일한 결과가 기준을 충족하지 못하면 자동으로 다시 생성하지 않고 해당 자산을 보류한 뒤 사용자에게 보고한다.
- 이미지 파일은 `resource/images/anomalies/<event_id>/<scene_id>/<state>.png`에 둔다.
- 음향 파일은 `resource/sounds/anomalies/<event_id>/<cue>.ogg`에 둔다.
- 점프스케어는 얼굴 중심 이미지 또는 짧은 영상과 전용 presentation scene을 한 묶음으로 관리한다.

### 1차 MVP SceneLock 이미지 범위

첫 유료 SceneLock 생성은 아래 일곱 결과를 대상으로 했다.

| 분류 | 대상 | 유료 생성 결과 |
| --- | --- | ---: |
| 엔티티 구성 요소 | 등록되지 않은 아이의 가짜 어머니 | 1 |
| 엔티티 | 이불 속 아이 | 이불 mound 1 |
| 엔티티 | 붉은 세탁기 | 붉은 사건 상태 1 |
| 기현상 | TV 귀신 | `active`, `hostile` 2 |
| 기현상 | 내장 욕조 | 발견 상태 1 |
| 기현상 | 빈 자살 로프 | 사건 상태 1 |

- 등록되지 않은 아이 본체는 새 이미지를 생성하지 않고 `resource/3d_models/dripping_gaze/dripping_gaze.glb`를 별도 인스턴스로 재사용한다.
- 기존 105호 욕실의 같은 모델 인스턴스는 이동하거나 덮어쓰지 않는다.
- 이 MVP에서는 생성형 이미지로 점프스케어 얼굴을 제작하지 않는다.
- 이 표 밖의 이미지는 2026-07-26 내장 ImageGen 기반 MVP 확장에서 추가했다.
- 총 유료 결과 수는 7장이고, 각 결과는 `candidate_count=1`이며 자동 재생성하지 않는다.

### 2차 MVP ImageGen 확장 — 2026-07-26

확정 목록을 실제 게임에서 한 번에 검수할 수 있도록 미제작 이미지도 임시
full-scene variant로 연결했다. 생성 목록, 프롬프트 의도와 교체 규칙은
[ImageGen MVP 자산 기록](imagegen-mvp-assets-2026-07-26.md)을 따른다.

2026-08-01에 모니터 존재, 유리문 존재의 두 상태와 지옥의 거울 RGBA 아이콘을 최종 이미지로 교체했다. 옷장의 돼지 가면 남자는 승인된 기존 참조 사진을 객실 합성과 점프스케어에 사용한다. 전화와 그림자는 각각 소리 중심, 비가시 엔티티이므로 별도 평상시 장면 이미지를 만들지 않는다.

### MVP SceneLock 작업 기록 — 2026-07-25

유료 생성을 시작하기 전 원본 여섯 장을 일곱 개의 불변 job으로 등록하고, 현재 런타임 overlay 좌표와 동일한 영역을 잠갔다. TV의 두 상태는 독립적인 accepted result와 receipt를 보존하기 위해 같은 원본에서 별도 job으로 만들었다.

| 대상 | Job ID | Locked selection ID | Source SHA-256 |
| --- | --- | --- | --- |
| 가짜 어머니 | `job_019f98740611b708b28c94fe144ea158` | `sel_019f9874ccf53eb1a00139e0dfdcfed4` | `668ddd1c70b50b78507bf3ceec9d2a4b25c50142df9c37e55399672d73b1c999` |
| 이불 속 아이 | `job_019f987387a2e7600c0581602aeeb437` | `sel_019f9874cf291457cbcc83a1e0c4283a` | `b96cab3b0ad0a50c97703b4c73c5060d80e6caebbab54cfc3e392cbd5febcfcb` |
| 붉은 세탁기 | `job_019f9874082810475734704b3452bfb0` | `sel_019f9874d05f1eec271cf862adcb61d2` | `a8f8d1ee81d1aae0a155a85bf1508935aa0c1be9b95b7b11f6ca19d325209d8f` |
| TV 귀신 `active` | `job_019f98740a40cb09ff9d179733ba61e2` | `sel_019f9874d2698503ea5caf02e81a6388` | `2a91c3eb4a57b932d51be09cfccc3568408a4cdfe237a9f5e1c8060d20da18c0` |
| TV 귀신 `hostile` | `job_019f987b5512cc53e682d8b71d3433d7` | `sel_019f987b69af867fb941557805988765` | `2a91c3eb4a57b932d51be09cfccc3568408a4cdfe237a9f5e1c8060d20da18c0` |
| 내장 욕조 | `job_019f98740c597605ee4ea14749b0610b` | `sel_019f9874d474aafcfc8e00281de47918` | `668ddd1c70b50b78507bf3ceec9d2a4b25c50142df9c37e55399672d73b1c999` |
| 빈 자살 로프 | `job_019f98740e7794079b397ed996878f31` | `sel_019f9874d67aa9859ff6416553272c96` | `7a4554e7c77990024109641eef99e559018469c440dd34cded42f333a1192926` |

- 이불 속 아이의 MVP 장면은 침대가 넓게 보이는 `room_108_bed_window`로 정했다.
- import 중 멈춘 로컬 요청은 SceneLock agent를 재시작한 뒤 해소됐으며, 유료 provider task는 발생하지 않았다.
- 현재 agent 상태는 OpenAI와 Gemini 자격 증명을 감지하지 못한다. provider가 `configured=true`가 되기 전에는 edit을 제출하지 않는다.
- candidate, run, accepted result와 receipt 값은 실제 생성·검수·승인 뒤에만 기록한다.

#### 제출 대기 중인 edit

모든 호출은 `candidate_count=1`, `provider_policy=auto_best`, `render_strategy=auto`를 사용한다. 잠긴 영역 밖의 카메라, 방 구조, 문, 가구, 조명 방향과 핫스폿 위치는 바꾸지 않는다.

| 상태 | Operation | Idempotency key | Edit instruction 요약 |
| --- | --- | --- | --- |
| 가짜 어머니 `active` | `insert` | `hotel-fake-mother-face02-composite-ai-v1-20260728` | 아이가 놓일 중앙 전경을 비우고, `room_106_fake_mother/reference_face_01.png`와 동일한 크게 뜬 창백한 눈·검은 눈두덩·검은 코·넓은 검은 미소·젖은 긴 머리를 가진 여성을 샤워 커튼 뒤에 둔다. 기존 환자복 몸과 욕실 구조는 유지한다. |
| 이불 속 아이 `active` | `structural_edit` | `hotel-mvp-20260725-edit-blanket-child-v1` | 침대의 기존 이불을 작은 아이가 무릎을 가슴에 붙이고 웅크린 크기의 mound로 바꾼다. 얼굴과 신체는 전혀 보이지 않고 기존 이불 무늬, 주름, 접촉 그림자와 광원을 유지한다. |
| 붉은 세탁기 `active` | `local_edit` | `hotel-mvp-20260725-edit-red-washer-v1` | 두 번째 세탁기의 유리와 드럼 내부만 포화된 짙은 적색으로 만들고 바로 주변 프레임에만 약한 붉은 반사를 준다. 문 형태와 조작부, 다른 세탁기는 유지하고 신체 부위는 넣지 않는다. |
| TV 귀신 `active` | `local_edit` | `hotel-mvp-20260725-edit-tv-ghost-active-v1` | TV 화면 안에 작은 화면에서도 읽히는 창백한 정면 얼굴을 CRT 정적과 함께 둔다. 표정은 비어 있고 무표정하며 TV 프레임과 벽은 유지한다. |
| TV 귀신 `hostile` | `local_edit` | `hotel-mvp-20260725-edit-tv-ghost-hostile-v1` | 같은 화면 위치에 눈을 더 크게 뜨고 입꼬리가 비정상적으로 올라간 악의적인 정면 얼굴과 강한 정적을 둔다. 화면 밖과 TV 프레임은 바꾸지 않는다. |
| 내장 욕조 `active` | `insert` | `hotel-mvp-20260725-edit-entrails-bathtub-v1` | 욕조 안을 식별 가능한 사람이나 팔다리 없이, 공포 영화의 정교한 실물 특수효과처럼 보이는 축축하고 얽힌 가상 내장으로 가득 채운다. 욕조 테두리, 커튼, 변기와 욕실 원근은 유지한다. |
| 빈 자살 로프 `active` | `insert` | `hotel-mvp-20260725-edit-empty-rope-v1` | 천장에 실제로 고정된 낡고 굵은 밧줄과 비어 있는 올가미를 침대 위에 매단다. 중력, 접촉 그림자와 방 원근을 맞추고 사람이나 시체는 넣지 않는다. |

### 현재 맵 원본 크기

SceneLock export와 full-canvas overlay는 아래의 **현재 실제 픽셀 크기**를 따라야 한다. 모든 장면이 같은 크기라고 가정하지 않는다.

| Scene | 원본 크기 | 이 장면의 확정 제작 대상 |
| --- | --- | --- |
| `front_desk` | 1535×1024 | 모니터 귀신, 유리문 얼굴, `"죽어"` 안내판, 전화 |
| `corridor` | 1536×1024 | 빨간 객실등, 피 웅덩이, 109호 열린 문 |
| `laundry_room` | 1195×896 | 아기 얼굴 다섯 면, 붉은 세탁기 |
| `exterior_stairs` | 1448×1086 | 지옥행 비상 화살표 |
| `room_105_door_window` | 1448×1086 | 객실등과 문 아래 사건의 객실 연결 상태 |
| `room_105_bathroom_entry` | 1535×1024 | 끔찍한 액자, TV 상태, 열린 옷장과 돼지 가면 남자 |
| `room_105_bathroom` | 1448×1086 | 샤워 커튼과 다리, 손자국 거울 |
| `room_106_bed_bathroom_entry` | 1448×1086 | 이불 속 아이 배치 후보 |
| `room_106_bathroom` | 1448×1086 | 샤워 커튼과 다리, 끔찍한 화장실 거울, 등록되지 않은 아이 |
| `room_107_bed_nightstand` | 1448×1086 | 빈 자살 로프, 목을 맨 목각 여자 인형 |
| `room_107_bathroom_entry` | 1448×1086 | 객실 전화와 옷장 상태 |
| `room_107_bathroom` | 1448×1086 | 인간 가죽 수건, 샤워 커튼과 다리 |
| `room_108_bed_window` | 1448×1086 | 이불 속 아이 배치 후보 |
| `room_108_bathroom_entry` | 1448×1086 | 108호 욕실 입구 일반 장면(TV 귀신은 105호에서 재생) |
| `room_108_bathroom` | 1448×1086 | 샤워 커튼과 다리, 내장 욕조 |

## 기현상

### 1. 모니터에 귀신의 형상

- ID: `front_desk_monitor_ghost`
- Scene: `front_desk`
- Logic: `idle -> active -> holding -> resolved`
- Hotspot: 모니터 전체. 현재 장면에 새 대형 핫스폿을 작성한다.
- Input: 마우스 홀드, 원형 진행 바
- Visual:
  - `active`: 모니터 화면 안의 흐린 상반신 형상
  - `off`: 검게 꺼진 모니터
  - 홀드 중 깜빡임은 runtime alpha로 처리
- Audio: 낮은 CRT hum, 홀드 중 전기 잡음, 완료 시 전원 꺼짐
- SceneLock: 모니터 화면 selection을 잠그고 `local_edit` 두 상태 제작
- QA: 작은 전원 버튼이 없고 모니터 전체에서만 진행되는지 확인

### 2. 유리문 너머 얼굴

- ID: `front_desk_glass_peeking_face`
- Scene: `front_desk`
- Logic: `peek -> first_triple_complete -> hostile -> second_triple_complete -> resolved`
- Hotspot: 기존 `desk_bell`; 얼굴은 클릭 대상이 아니다.
- Input: 허용 시간 안의 빠른 3연타 두 묶음
- Visual:
  - `peek`: 유리문 프레임 밖 얼굴 절반
  - `hostile`: 같은 위치의 악독한 표정
- Audio: 기존 벨 cue 재사용, 두 번째 묶음 완료 시 얼굴이 사라지는 짧은 마찰음
- SceneLock: 얼굴 asset을 원근·야간 유리 반사에 맞춰 `submit_image_composite`
- QA: 첫 3연타 뒤 위치가 변하지 않고 표정만 바뀌는지 확인

### 3. `"죽어"` 안내판

- ID: `front_desk_death_sign`
- Scene: `front_desk`
- Logic: `active -> holding -> resolved`
- Hotspot: 왼쪽 체크아웃 안내판 전체
- Input: Hand 상태 무관 마우스 홀드
- Visual: 붉고 거친 `"죽어"` 글씨가 있는 안내판 variant
- Audio: 손가락이 표면을 긁는 낮은 소리, 완료 시 원래 안내판 ambience 복귀
- SceneLock: 안내판 selection에 `object_variant`; 실제 휘갈긴 글씨 사진으로 나중에 교체 가능
- QA: 장착 아이템별로 동일하게 작동하고 별도 메시지가 없는지 확인

### 4. 빨간색 객실등

- ID: `corridor_red_room_light`
- Scene: `corridor`
- Logic: 승인된 105호 위치에 고정하며 대상 객실을 재추첨하지 않음
- Hotspot: 105호 객실등과 주변 광번짐을 포함한 큰 영역
- Input: 마우스 홀드
- Visual:
  - 105호 적색 조명과 벽·문 아래 광번짐 full-scene variant 1장
  - 홀드 중 깜빡임은 alpha와 정상 사진 교차
- Audio: 전기 buzz와 완료 click
- SceneLock: 105호 객실등 selection으로 `tone_light`; 기본 사진 전체 노출과 다른 방 조명 보존
- QA: 105호 안 사진은 바뀌지 않고 복도만 변하며 저장·재시작에도 위치가 바뀌지 않는지 확인

### 5. 문 아래 피 웅덩이

- ID: `corridor_blood_puddle`
- Scene: `corridor`
- Logic: 승인된 105호 문 아래 위치에 고정하며 대상 객실을 재추첨하지 않음
- Hotspot: 105호 문 아래 바닥의 넓은 영역
- Input: `cleaning_cloth` 장착 후 `F` 홀드
- Visual:
  - 105호 피 웅덩이 full-scene variant 1장
  - 홀드 진행도에 따라 아래에서 위로 mask를 줄여 문 밑으로 되빨려 들어가는 것처럼 표현
- Audio: 젖은 닦임, 문 안쪽으로 빨려 들어가는 소리
- SceneLock: 바닥 원근과 반사를 보존한 `object_insert`
- QA: 105호 동선 점유 사건과 동시에 활성화되지 않고 다른 객실 위치로 이동하지 않는지 확인

### 6. 아기 얼굴 벽지

- ID: `laundry_baby_face_surfaces`
- Scene: `laundry_room`
- Logic: `open_surface_mask` 5비트
- Hotspot: 바닥·천장·왼쪽·정면·오른쪽의 다섯 대형 영역
- Input: 면 단위 상호작용. 최종 hold 길이는 튜닝 가능하나 면 단위 구조는 고정
- Visual:
  - 다섯 면 각각 `eyes_open`, `eyes_closed`
  - 전체 조합 32장의 full variant를 만들지 않는다.
  - 원근에 맞춘 면별 투명 레이어 10장을 독립 합성한다.
- Audio: 면 처리마다 짧은 울음 1회, 마지막 면 뒤 즉시 무음
- SceneLock: 면별 polygon selection을 lock하고 `structural_edit`; 인접 설비 protect mask 사용
- QA: 한 얼굴씩 클릭할 수 없고 저장·로드 후 5비트 상태가 유지되는지 확인

### 7. 인간 가죽 수건

- ID: `room_107_human_skin_towel`
- Scene: `room_107_bathroom`
- Logic: `active -> holding -> resolved`
- Hotspot: 수건과 걸이 전체
- Input: Hand 상태 무관 마우스 홀드
- Visual: 얼굴이나 완전한 신체 부위가 없는 젖은 가죽 variant
- Audio: 젖은 천을 떼는 소리
- SceneLock: 수건 selection의 `object_variant`; 주변 거울과 벽 protect
- QA: 가죽이 움직이거나 플레이어를 붙잡는 연출이 없는지 확인

### 8. 지옥행 비상 화살표

- ID: `corridor_hell_exit_arrow`
- Scene: `exterior_stairs`를 주 화면으로 사용하고 복도 진입부에는 단서 오버레이만 둔다.
- Logic: `active -> holding -> resolved`
- Hotspot: 붉은 유도등과 화살표 전체
- Input: Hand 상태 무관 마우스 홀드
- Visual:
  - 유도등·붉은 광번짐·계단 끝 검은 막힘을 포함한 full-scene variant
  - 실제 새 공간과 이동 target은 추가하지 않는다.
- Audio: 형광등 hum, 아주 먼 군중 소리, 완료 시 정상 빗소리 복귀
- SceneLock: 조명 변화가 넓으므로 `structural_edit`
- QA: 계단을 눌러 별도 지옥 scene으로 이동하지 않는지 확인

### 9. 끔찍한 얼굴 액자

- ID: `room_105_grotesque_portrait`
- Scene: `room_105_bathroom_entry`
- Logic: `active -> holding -> resolved`
- Hotspot: 왼쪽 액자 전체
- Input: Hand 상태 무관 마우스 홀드
- Visual: 피부가 흐르고 입이 비정상적으로 벌어진 정지 얼굴
- Audio: 낮은 캔버스 마찰음
- SceneLock: 액자 내부만 `object_variant`
- QA: 눈동자 추적과 액자 밖 이동이 없는지, 옷장의 돼지 가면 남자와 충돌하지 않는지 확인

### 10. TV 귀신

- ID: `room_108_tv_ghost`
- Scene: `room_105_bathroom_entry` (`room_108_tv_ghost`는 세이브 호환용 레거시 ID)
- Logic: `active -> holding -> hostile -> resolved`
- Hotspot: TV 전체
- Input: 마우스 홀드, 원형 진행 바
- Visual:
  - `active`: 최초 형상
  - `hostile`: 더 악독하게 웃는 표정
  - `off`: 검게 꺼짐
  - 잡음과 깜빡임은 shader
- Audio: 홀드 비율에 따른 잡음 volume 증가, 완료 시 click
- SceneLock: 작은 화면 가독성을 우선한 `local_edit` 두 상태
- QA: 플러그와 작은 전원 버튼이 없으며 형상이 화면 앞으로 이동하지 않아도 공포 피드백이 읽히는지 확인

### 11. 닫힌 샤워 커튼과 다리

- ID: `bathroom_shower_legs`
- Scene: `room_105_bathroom`부터 `room_108_bathroom`까지
- Logic:
  - 발생 시 `result=empty|legs`
  - 105~108호 욕실 중 한 곳을 한 번 추첨하고 Day 저장 상태에 고정
  - `legs`이면 `required_open_count=3..5`를 한 번 저장
  - 열기 횟수 누적 후 빈 욕조로 전환
- Hotspot: 기존 샤워 커튼 대형 영역
- Input: 클릭으로 닫기·열기 반복
- Visual:
  - 기존 닫힌 커튼 사진 4장 재사용
  - 각 욕실의 다리 variant 4장
  - 빈 욕조는 기본 사진
- Audio: 최초 다리 발견 때만 짧은 강공포 cue, 커튼 마찰음
- SceneLock: 각 욕실 욕조 selection에 같은 다리 asset을 원근별 `ai_integrate`
- QA: 반복 목표가 사건 시작 후 변하지 않고 UI에 남은 횟수를 표시하지 않는지 확인

### 12. 빈 자살 로프

- ID: `room_107_empty_hanging_rope`
- Scene: `room_107_bed_nightstand`
- Logic: `active -> holding -> resolved`
- Hotspot: 로프와 아래 공간을 포함한 큰 영역
- Input: Hand 상태 무관 마우스 홀드
- Visual: 빈 올가미와 넘어진 의자, 사람·그림자 없음
- Audio: 약한 로프 마찰
- SceneLock: 천장·바닥을 함께 잠근 `submit_image_composite`
- QA: 목을 맨 목각 여자 인형과 동시 발생하지 않고 작은 천장 고리를 누를 필요가 없는지 확인

### 13. 손자국 거울

- ID: `room_105_bloody_handprint_mirror`
- Scene: `room_105_bathroom`
- Logic: `active -> holding -> resolved`
- Hotspot: 거울 전체
- Input: `cleaning_cloth` 장착 후 `F` 홀드
- Visual:
  - 크기가 다른 붉은 손자국 오버레이
  - 홀드 진행도에 따른 좌우 wipe mask
- Audio: 유리 닦임과 젖은 마찰
- SceneLock: 거울 selection `object_insert`; 플레이어 또는 별도 귀신 반사 금지
- QA: 옷장의 돼지 가면 남자 활성 중 발생하지 않는지 확인

### 14. 끔찍한 화장실 거울

- ID: `room_106_horrific_bathroom_mirror`
- Scene: `room_106_bathroom`
- Logic: `active -> transfer_holding -> resolved`, 이어서 item hazard 시작
- Hotspot: 거울 전체
- Input: `small_mirror` 장착 후 `F` 홀드
- Visual:
  - 실제 욕실은 정상이고 거울 내부만 훼손된 다른 화장실
  - 처리 완료 시 정상 거울
  - `small_mirror`, `hell_mirror` 인벤토리 아이콘
- Audio: 전달 완료 순간 영혼의 절규, Hand 장착 중 매우 작은 loop
- Actions:
  - `replace_item(small_mirror, hell_mirror, equip=true)`
  - 확정 사건 대사 한 번
  - equipped item hazard 시작
- SceneLock:
  - 거울 내부 selection `structural_edit`
  - 아이템 아이콘은 별도 투명 배경 생성
- QA:
  - 일반 완료 메시지는 없고 확정 대사만 표시
  - 변환 직후 Hand에 `hell_mirror`
  - 내려놓으면 loop 정지
  - Hand에 12초 유지 시 사망, 내려놓으면 시간 초기화
  - 두 번째 세탁기에 사용하면 문이 닫히고 파손음과 함께 제거
  - 근무 종료까지 인벤토리에 남으면 사망

### 15. 내장으로 가득한 욕조

- ID: `room_108_entrails_bathtub`
- Scene: `room_108_bathroom`
- 확정 제작 범위: 외형, 욕조 전체 4.2초 hold, resolved 전이와 배수음을 제작한다.
- Visual:
  - 욕조 전체를 채운 검붉은 물과 끔찍한 내장
  - 실시간으로 미끄러지거나 움직이는 내장 애니메이션 없음
  - 작은 배수 마개·수도꼭지 오브젝트 추가 없음
- Hotspot: 욕조 전체의 기존 대형 영역을 사용한다.
- Audio: hold 완료 시 4.4초 물 배수·배관 gurgle cue를 재생한다.
- SceneLock: 욕조와 물 표면 selection을 잠근 `structural_edit`; 변기·세면대·거울·커튼은 protect한다.
- QA:
  - 108호 욕실 원근과 조명 유지
  - 내장이 욕조 바깥 바닥으로 움직이거나 플레이어를 붙잡지 않음
  - Day 3부터 production queue에 포함하며 하루 한 번의 기현상 제한을 따름

## 확정 엔티티

### 옷장의 돼지 가면 남자

- 정사 엔티티명: `옷장의 돼지 가면 남자`
- ID: `room_105_closet_pig_man`
- Scene: `room_105_bathroom_entry`
- Logic:
  - 90초 최초 대기 뒤 한쪽 눈이 보이는 `door_open`
  - 45초 뒤 두 눈과 가면 대부분이 보이는 `emerging`
  - 다시 30초 방치 시 전역 사망
  - 제한시간 종료 시 전역 사망
- Visual:
  - 1단계는 거의 닫힌 옷장문의 좁은 검은 틈과 한쪽 눈·주둥이 일부
  - 2단계는 더 열린 문틈 속 두 눈과 가면 대부분
  - 목, 어깨, 가슴, 팔과 하체를 옷장문과 어둠으로 완전히 가림
  - 남자가 문 밖으로 걸어 나오는 full-body 상태는 만들지 않음
- Input: 옷장 hotspot을 5초간 마우스 홀드해 남자를 밀어 넣고 문을 닫음
- Audio: 각 단계 시작 시 한 번, 활성 중 24~42초 간격의 전역 돼지 울음, 퇴각·문 닫힘
- SceneLock: 옷장 selection을 두 상태로 고정하고 장면 나머지를 protect
- QA: 다른 장면에서도 타이머와 전역 울음이 진행되고, 홀드 중단 시 진행도가 초기화되는지 확인

### 받지 못한 전화

- ID: `room_108_light_repair_call`
- Scene: `front_desk`, 지목 객실은 현재 `room_108`
- Logic:
  - 반복 벨
  - 제한 전 수신
  - 통화 뒤 객실 금지 타이머
  - 미수신 시 수화기 드는 소리·웃음·짧은 유예·전역 사망
- Visual: 전화 상태 강조는 최소화하고 점프스케어 얼굴만 전용 제작
- Input: 프런트 전화 클릭
- Audio: 벨, 수화기, 통화, 웃음, 사망 전 정적
- QA: 전화선 연출 없음, 금지 객실 진입 시 사망, 금지 시간이 영구 플래그가 아님

### 붉은 세탁기

- ID: `laundry_red_washer`
- Scene: `laundry_room`
- Logic: `washing -> red -> music -> ready -> discarded`
- Visual:
  - 시뻘건 유리와 내부
  - 세탁기 속도 변화 없음
  - 열린·닫힌 기본 문 상태와 사건 상태를 독립 관리
- Input:
  - 붉을 때 세탁기 정지
  - 음악 중 조작·이탈 금지
  - 음악 종료 뒤 눈 감고 폐기
- Audio: 평소 회전음, 완료 음악, 사망 점프스케어
- SceneLock: 두 번째 세탁기 유리 selection의 `tone_light` 및 내부 red variant
- QA: 작은 비명·가속 없음, 음악과 다른 이상현상 음향이 겹치지 않음

### 등록되지 않은 아이

- ID: `room_106_abandoned_child`
- Scene: `room_106_bathroom`
- Logic: `waiting -> crying -> singing -> resolved`
- Visual:
  - 아이 형상
  - 손을 뻗는 진정 상태
  - 이전 문틈 여성의 최종 얼굴을 계승한 가짜 어머니 형상
  - 얼굴 중심 사망 이미지
- Input:
  - 이탈 금지
  - 눈 감기
  - `F`가 노래 부르기로 문맥 전환
  - 눈을 감으면 `F` 노래 안내 표시
  - 가로형 진행 바 완료 뒤 자동으로 눈을 뜨고 즉시 해결
- Audio: 울음, 노래, 가짜 어머니 cue, 실패 점프스케어
- SceneLock: 아이와 가짜 어머니를 독립 full-canvas overlay로 제작
- QA: 화장실 밖에 어머니가 나타나지 않고, 노래하지 않은 시간만 사망 카운트에 포함

### 이불 속 아이

- ID: `vacant_room_child_under_blanket`
- Scene: 비어 있는 객실의 침대. 첫 구현은 한 객실로 고정한 뒤 장면별 asset을 추가한다.
- Logic: `encountered -> eye_wait -> resolved | fatal`
- Visual:
  - 웅크린 아이 형태의 이불 mound
  - 해결 후 기본 평평한 침대
  - 얼굴 중심 점프스케어
- Input:
  - 침대·이불 클릭과 아이템 사용 즉사
  - 같은 방에서 눈 감기 유지
  - 하단 가로형 진행 바
- Audio:
  - 주기적 웃음과 단계별 변조
  - 모든 locale 공통 일본어 `"미츠케타—"`
- SceneLock: 선택한 객실 침대 selection에 `structural_edit`; 이불 무늬와 광원 보존
- QA: 눈 감는 동안 사망 카운트 정지, 웃음은 계속, 아이 신체 직접 노출 없음

## 부분 구현 엔티티의 확정 제작 범위

다음 세 엔티티의 탐지, 성장, 위험, 해결과 사망 연출을 각각의 확정 상태에 맞춰 관리한다. 성공 흐름이 아직 없는 엔티티만 본편 스케줄에서 제외하고 debug state로 검수한다.

### 109호의 열린 문

- ID: `room_109_open_door`
- Scene: `corridor`; Day 7 통과 연출은 복도 전역 audio sequence
- 확정 Logic:
  - Day 3부터 열린 문 출현
  - 문 안쪽을 누르거나 들여다보면 존재가 플레이어를 인식하고 전역 방치시간 시작
  - Day 7에는 문을 열어 두고 존재를 막지 않으며, 발소리가 멎기 전에 돌아보면 사망
- Visual:
  - `open_unseen`: 109호 문과 빛이 닿지 않는 내부. 전신이나 얼굴을 평상시에는 보여주지 않음
  - `day7_open`: 같은 문의 마지막 날 상태
  - `fatal`: 얼굴 중심 점프스케어
- Audio:
  - 초기 문 안쪽의 거의 들리지 않는 기척
  - Day 7 문 통과, 플레이어 뒤를 지나가는 발소리와 완전한 정적
- SceneLock:
  - 현재 corridor 원본에 109호가 자연스럽게 이어지도록 문 전체를 `structural_edit`
  - Day 7의 지나가는 존재는 정면 full-body 이미지 대신 가림·그림자 없는 audio 중심으로 제작
- QA:
  - 열린 내부 클릭은 기존 navigation과 구분된 대형 동적 핫스폿
  - 초기 해결법 placeholder 없음
  - Day 7에 막기·돌아보기 판정 hook만 정의하고 입력 의미는 기존 눈 감기나 아이템 처리로 대체하지 않음

### 그림자

- ID: `hotel_following_shadow`
- Scene: 객실 구역과 복도 전역
- 확정 Logic:
  - 발동 UI와 시각 경고 없음
  - 다음 이동부터 플레이어 발소리 또는 문 여는 소리가 같은 고정 간격으로 한 번 더 재생
  - 복제 간격은 점점 짧아지지 않음
  - 프런트 벨을 울리면 그림자도 고정 간격 뒤 벨을 따라 울림
  - 벨을 여러 번 빠르게 울리면 그림자가 비명을 지르며 `bell_distressed`로 전환
  - `bell_distressed`에서는 플레이어 심장 소리와 화면 점멸이 시작됨
  - 이어서 방을 여러 번 빠르게 오가는 장면 이동을 반복하면 마지막 비명과 함께 해결
  - 전역 방치시간 종료 시 어느 장면에서든 사망
- Visual:
  - `attached`에서는 실루엣, 발자국, VHS와 화면 왜곡을 추가하지 않음
  - `bell_distressed`에서만 화면 전체를 빠르게 점멸하며 엔티티의 형상은 계속 보여주지 않음
  - `fatal`에서만 사람과 닮았지만 사람이 아닌 얼굴을 화면 전체에 표시
- Audio:
  - scene transition의 원본 이동 cue와 지연 복제 cue를 분리
  - 원본 프런트 벨과 지연 복제 벨 cue를 분리
  - 벨 연타 임계 도달 비명, `bell_distressed` 심장 소리, 해결 비명을 분리
  - 제한시간 종료 직전 플레이어 바로 뒤에서 마지막 복제 발소리, 짧은 정적
- SceneLock: 평상시 장면 편집 없음. 얼굴 중심 fatal asset만 독립 제작
- QA:
  - 같은 scene 이동을 반복해도 복제 간격이 고정
  - 느린 벨 입력은 연타로 판정하지 않지만 매 입력마다 복제 벨은 재생
  - `bell_distressed` 이전에는 심장 소리와 화면 점멸이 없음
  - 빠른 방 왕복 요구 횟수를 채우기 전에는 해결되지 않음
  - 해결 시 비명 뒤 복제 소리, 심장 소리와 화면 점멸이 모두 멎음
  - 다른 이상현상 audio와 동시 재생 없음
  - 그림자가 처음 등장할 수 있는 Day의 룰북에 `"누군가 따라온다면 벨을 여러 번 빠르게 울리고 도망치십시오."`를 노출

### 목을 맨 목각 여자 인형

- ID: `room_107_hanging_girl`
- Scene: `room_107_bed_nightstand`
- 확정 Logic:
  - 처음 클릭하면 `대화한다`와 `무시한다` 중 하나를 고름
  - 무시하거나 대화를 닫아도 전역 방치시간은 계속 흐름
  - 방치시간 임박 신호는 웃음소리만 사용
  - 세탁실 탁자의 `귀여운 인형`은 획득 후 Hand에 장착 가능
  - 해결 선택지는 Hand 장착 여부와 무관하게 인벤토리 보유만 검사
  - `윌터는 재미있어 보인대` → `내 인형 친구야`에서 인형을 건네면 해결
  - 나머지 모든 대화 오답과 최종 제한시간 종료는 사망
- Visual:
  - 여자아이 형태지만 피부가 아닌 낡은 목각 인형
  - `재미없어 보여` 뒤에는 검은 두 눈과 붉은 동공만 추가
  - 방치 경고용 발끝·그림자·화면 침범 등 별도 시각 변화 없음
  - `fatal`은 방 전체 사진을 노출하지 않고 목각 여자 인형의 상반신만 크롭해 얼굴 방향으로 빠르게 돌진
- Audio: 첫 발견 웃음, 제한시간 임박 웃음, fatal cue
- SceneLock:
  - 천장 로프와 목각 여자 인형을 한 locked selection으로 관리
  - 승인된 `room_107_bed_nightstand/visible.png`를 조우와 점프스케어 원본으로 공용하되, 점프스케어는 런타임에서 인형 상반신만 크롭
- QA:
  - 빈 자살 로프 기현상과 동시 발생하지 않음
  - 욕설은 정색하는 순간에 한 번만 출력
  - 골라본 선택지는 저장·복원 뒤에도 표시하며 다시 선택 가능
  - 오답 사망 서술은 추가 대사 없이 빠르게 출력
  - 올바른 선택지는 `귀여운 인형` 보유 시에만 보이며 해결 시 인형 소비

## 룰북 이미지

- `resource/images/rule_book/day_01.png`부터 `day_07.png`
- locale 우선 파일은 `resource/images/rule_book/<locale>/day_XX.png`
- 실제 종이에 휘갈겨 쓴 촬영본으로 교체해도 코드 변경이 없어야 한다.
- 페이지에는 그 Day에 새로 추가된 규칙만 넣는다.
- 텍스트 fallback은 모든 이미지가 승인되기 전까지 유지한다.

## 구현 순서

### 0. 공통 기반

- 전역 single-active scheduler
- hold UI
- 프레젠테이션 매니페스트와 레이어 스택
- anomaly audio bus
- item hazard controller

### 1. 낮은 위험의 수직 슬라이스

1. `"죽어"` 안내판
2. 모니터 귀신
3. 손자국 거울

세 사건으로 무도구 hold, 이미지 layer, 아이템 hold를 모두 검증한다.

### 2. 상태 변화 기현상

- 유리문 얼굴
- 빨간 객실등
- 피 웅덩이
- TV 귀신
- 샤워 커튼과 다리
- 아기 얼굴 다섯 면
- 인간 가죽 수건
- 지옥행 화살표
- 끔찍한 액자
- 빈 자살 로프

### 3. 아이템 변환

- 작은 거울 획득 hook만 마련
- 끔찍한 화장실 거울
- 지옥의 거울 Hand 위험
- 지옥의 거울 두 번째 세탁기 폐기와 근무 종료 fatal 연결

### 4. 확정 엔티티

- 옷장의 돼지 가면 남자
- 받지 못한 전화
- 붉은 세탁기
- 등록되지 않은 아이
- 이불 속 아이
- 그림자
- 목을 맨 목각 여자 인형

### 5. 보류 항목

- Day 3의 109호 초기 조우 성공 처리법만 보류한다.
- Day 7의 109호 통과, 내장 욕조, 그림자, 지옥의 거울 사용처는 production handler와 QA까지 연결했다.
- 초기 109호 사건에는 placeholder 해결, 임시 퇴치 버튼과 자동 해제를 넣지 않는다.
