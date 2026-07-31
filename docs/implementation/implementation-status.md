# 이상현상 구현 상태

이 문서는 확정 설계와 실제 코드·자산 상태를 구분한다. “계획됨”을 “게임에 구현됨”으로 오해하지 않도록 각 단계의 증거를 기록한다.

## 현재 완료된 기반

| 기반 | 상태 | 증거 |
| --- | --- | --- |
| 일반 클릭과 Hand 아이템 사용 분리 | 코드·테스트 완료 | `HotelInteractionActionRunner.execute_hotspot`, `execute_item_on_hotspot` |
| 잘못된 아이템 사용 시 무반응 | 코드·테스트 완료 | item-only target 테스트와 일반 클릭 회귀 테스트 |
| 같은 슬롯 아이템 변환·자동 장착 | 코드·테스트 완료 | `HotelInventoryModel.replace_item_by_id`, `replace_item` action |
| `small_mirror`, `hell_mirror` 등록 | 코드·자산·테스트 완료 | item catalog, 한국어·영어 localization, 투명 PNG와 UI raster icon fallback |
| hold 진행 상태기 | 코드·테스트 완료 | reset/pause 정책과 start/progress/cancel/complete signal |
| 전역 single-active 스케줄러 코어 | 코드·테스트 완료 | priority queue, conflict defer, cooldown, save/import |
| SceneLock presentation manifest 계약 | 문서·스키마·검증기 완료 | JSON Schema, source scene/path, SHA-256, canvas와 layer slot 검증 |
| 룰북 이미지 교체 기반 | 기존 코드·테스트 완료 | locale 이미지 우선, 공용 이미지와 텍스트 fallback |

## 현재 연결된 런타임

| 작업 | 현재 상태 | 완료 조건 |
| --- | --- | --- |
| 기존 `NightAnomalyDirector` 단일 활성화 | 연결 완료 | phone, washer, child, blanket 중 하나만 tick하며 외부 콘텐츠·곰팡이 엔티티와 상호 차단 |
| 확정 기현상 전역 scheduler | 연결 완료 | 하루 최대 2개, 하나의 active ID, cooldown과 save/import |
| 원형·가로형 진행 바 실제 UI | 연결 완료 | 마우스 hold는 커서 원형, 노래·눈 감기는 하단 가로 UI |
| presentation layer stack | 연결 완료 | 검증된 manifest의 full variant/layers를 로드하며 없으면 procedural 검수 레이어 사용 |
| `Anomaly` audio bus | 연결 완료 | 벨·울음·웃음·절규·TV 잡음·그림자 echo·비명·심장 loop와 지옥 거울 loop |
| `EquippedItemHazardController` | 연결 완료 | 지옥의 거울 자동 장착, Hand 시간, 절규 증가, 내려놓기, fatal |
| debug event panel | 연결 완료 | 확정 기현상과 부분 구현 엔티티의 외형·위험 상태를 Day 대기 없이 강제 검수 |

## 확정 콘텐츠 구현 범위

- 14개 해결 가능 기현상은 실제 hotspot과 처리 상태를 갖는다.
- `room_108_entrails_bathtub`은 외형만 검수 가능하며 처리 hotspot을 만들지 않았다.
- 곰팡이 돼지 가면 남자, 받지 못한 전화, 붉은 세탁기, 등록되지 않은 아이, 이불 속 아이는 확정 처리와 방치 사망 흐름을 갖는다.
- `room_109_open_door`는 외형·탐지·전역 fatal만 구현했고 성공 처리법은 만들지 않았다.
- `room_107_hanging_girl`은 발동과 동시에 세탁실 탁자에 인형을 만들고, 클릭 획득·Hand 장착·선택지 대화·선택 이력 표시·룰북 단서·비장착 상태의 인형 전달 해결·오답 사망 서술을 구현했다. Preview는 세탁실 인형 획득부터 시작해 107호 생존 루트까지 이어진다. 목각 여자 인형은 기존 `resource/images/anomalies/room_107_hanging_girl/room_107_bed_nightstand/visible.png`를 조우·적대 상태·점프스케어 원본으로 공용하며, 점프스케어에서는 방 전체 대신 인형 상반신만 런타임 크롭해 돌진시킨다.
- `hotel_following_shadow`은 Day 3부터 production queue에 등장한다. 이동음과 프런트 벨 복제, 빠른 벨 3연타 반응, 비명·심장 소리·화면 점멸, 2.2초 간격 안의 복도↔객실 경계 4회 반복 성공 판정, 저장·복원과 전역 fatal까지 연결됐다.
- 모든 production 기현상은 같은 시간에 하나만 활성화된다. 해결법이 없는 부분 구현 엔티티는 production queue에 넣지 않고 debug 검수로만 열어 두었다.

## 콘텐츠와 자산

- 이상현상별 Logic, Hotspot, Visual, Audio, SceneLock와 QA 단위는 [콘텐츠 제작 계획](anomaly-content-production-plan.md)에 있다.
- 현재 SceneLock 실행 파일은 설치되어 있으나 이 Codex 세션에 호출 가능한 SceneLock tool namespace가 노출되지 않았다. 따라서 실제 SceneLock job, accepted candidate와 receipt는 아직 없다.
- 실제 합성 이미지가 없는 상태에서도 로직을 전부 검수할 수 있도록 procedural 프리뷰를 사용한다. 검증된 manifest와 이미지가 들어오면 같은 event/state ID로 자동 대체된다.
- `small_mirror`와 `hell_mirror`는 런타임 ID·텍스트·변환·자동 장착·Hand 위험과 각각의 투명 PNG 아이콘까지 연결됐다. 인벤토리, drag preview, Hand 슬롯과 장비 HUD가 같은 아이콘을 사용한다.
- 이불 속 아이의 공용 일본어 `みーつけた。` 음성은 `res://resource/sounds/anomalies/blanket_found_ja.ogg`에 있으며, 라이선스·생성·후처리 기록은 `resource/sounds/licenses/blanket_found_ja.md`에 보존한다. 파일이 없을 때만 개발용 타이밍 합성음으로 fallback한다.
- 외부 음향을 추가할 때는 `resource/sounds/licenses/`에 출처와 라이선스를 함께 저장해야 한다.

## 보류 경계

다음은 해결법 또는 추가 용도만 보류한다.

- 지옥의 거울 추가 사용처
- 내장 욕조 해결법
- 109호 초기 조우 해결법

이 사건들의 이미 확정된 외형, 탐지, 위험, 성장과 fatal 연출은 제작 계획에 포함하지만, 성공 가능한 본편 handler는 해결법 확정 전 활성화하지 않는다.
