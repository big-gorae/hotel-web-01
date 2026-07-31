# ImageGen MVP 자산 기록 — 2026-07-26

## 제작 모드

- 도구: Codex 내장 ImageGen
- 모드: 기존 호텔 사진을 입력한 단일 결과 이미지 편집
- 후보 수: 자산당 1장
- 후처리: 원본 캔버스 크기에 맞춘 강제 리사이즈
- 목적: 최종 미술이 아니라 기현상 식별, 클릭 위치, 상태 전환 검증

## 생성 자산과 프롬프트 의도

| 이벤트 | 장면 | 프롬프트 핵심 |
| --- | --- | --- |
| `corridor_red_room_light` | `corridor` | 한 객실등만 포화된 적색으로 바꾸고 주변 벽에 붉은 광번짐 추가 |
| `corridor_blood_puddle` | `corridor` | 객실 문 아래에서 불규칙한 공포영화용 붉은 액체가 새어 나온 상태 |
| `laundry_baby_face_surfaces` | `laundry_room` | 실제 피해 아동이 아닌 기괴하게 우는 아기 인형 얼굴 무늬로 벽·천장 도배 |
| `room_107_human_skin_towel` | `room_107_bathroom` | 수건을 사람 피부처럼 보이는 주름진 라텍스 특수분장 소품으로 교체 |
| `stairs_hell_arrow` | `exterior_stairs` | 계단 아래 벽에 아래쪽을 가리키는 시뻘건 발광 화살표와 광번짐 추가 |
| `room_105_grotesque_portrait` | `room_105_bathroom_entry` | 기존 액자 안 풍경을 비대칭 눈과 지나치게 넓은 미소의 낡은 초상화로 교체 |
| `bathroom_shower_legs` | `room_105_bathroom` | 열린 커튼 뒤 욕조에 누운 정체불명 성인의 창백한 두 다리만 노출 |
| `room_105_bloody_handprint_mirror` | `room_105_bathroom` | 거울 표면에만 공포영화용 붉은 손자국과 흘러내린 자국을 밀집 배치 |
| `room_106_horrific_mirror` | `room_106_bathroom` | 거울 속에만 끝없이 이어진 오염된 욕실과 서리 유리 뒤 영혼 실루엣 표시 |
| `room_109_open_door` | `corridor` | 109호 문만 열고 내부는 인물이나 눈 없이 완전한 암흑으로 처리 |
| `room_107_hanging_girl` | `room_107_bed_nightstand` | 실제 피해 아동 대신 긴 팔다리의 낡은 여자아이 마네킹을 천장에 매단 MVP 대역 |

## 2026-07-26 교체

- `room_107_hanging_girl`: 기존 장면을 입력으로 사용해 방·몸·밧줄은 유지하고 얼굴과 시선만 카메라 정면으로 수정했다.
- `room_108_tv_ghost`: 높은 TV가 있던 108호 장면 대신 책상 높이의 CRT가 있는 `room_105_bathroom_entry`로 이전했다. 평상 상태는 정적 속 흐린 형상, 길게 누르는 중반 이후에는 잡음과 미소가 강해지는 적대 상태를 사용한다.

## 생성하지 않은 자산

아래 네 항목은 얼굴 해석과 이미지 검열 문제 때문에 생성하지 않았다.

- `front_monitor_ghost`
- `front_glass_face`
- `room_105_closet_woman` — 곰팡이 돼지 가면 남자(세이브 호환용 레거시 ID)
- `hell_mirror`

앞의 세 장면은 기존 사진 위 검은 사각형 full-scene variant로 연결했다.
`hell_mirror`는 512×512 검은 아이콘으로 교체했다.

## 직접 합성

`front_die_sign`은 생성 모델의 한글 오류를 피하기 위해 기존 체크아웃
안내판 위에 `"죽어"` 글자를 직접 합성했다.

## 교체 규칙

최종 이미지가 준비되면 `resource/images/anomalies/<event>/<scene>/<state>.png`
경로를 유지한 채 PNG를 교체하고 해당 매니페스트의 SHA-256을 갱신한다.
`hell_mirror.png`도 같은 경로에서 최종 아이콘으로 바꿀 수 있다.
