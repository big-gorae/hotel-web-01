# 확정 이야기 구현 계획

## 범위

이 문서는 [확정 사항 원장](../anomaly-bible/confirmed-decisions.md)의 이야기 설정을 게임 안에서 전달하기 위한 구현 단위로 바꾼다. 새로운 범인, 언니의 생사, 관리자의 정체와 결말을 확정하지 않는다.

## 플레이어가 반드시 이해해야 하는 사실

1. 플레이어는 언니가 아니라 빚을 피해 잠적 중인 동생이다.
2. 동생은 도박 중독으로 빚이 많고 불법적인 일에도 관여했다.
3. 언니는 이 동생이 호텔에서 실종 또는 납치됐다는 이야기를 조사하려고 동생 이름으로 호텔에서 근무했다.
4. 언니는 근무 연락처 두 개를 등록했고, 두 번째 번호가 동생의 현재 번호다.
5. 호텔은 그 두 번째 번호로 전화해 밀린 임금을 받으러 오라고 한다.
6. 플레이어는 빚 때문에 수상함을 감수하고 근무를 수락한다.
7. `"동생을 찾으러 왔다고 말하지 마"`라는 문장은 플레이어 자신이 그 동생이라는 모순을 만든다.
8. 관리자는 정체가 드러나지 않으며 룰북 규칙만 계속 추가한다.

이 사실을 한 통화에서 전부 설명하지 않는다. 현재 구현은 Day 시작마다 한 조각씩 전달하며, 이후 기록지·사진 같은 실물 자산으로 교체해도 같은 beat ID와 저장 진행도를 유지한다.

## 현재 Day별 전달표

| Day | beat ID | 전달 내용 |
| --- | --- | --- |
| 1 | `story.unpaid_wages_call`, `story.debt_forces_acceptance` | 밀린 임금 전화와 빚·불법 일 때문에 제안을 무시할 수 없는 사정 |
| 2 | `story.previous_shift_under_player_name` | 플레이어 이름의 이전 근무 기록과 두 연락처 |
| 3 | `story.second_contact_matches_player` | 두 번째 연락처가 잠적 후 바꾼 플레이어 번호임을 확인 |
| 4 | `story.previous_worker_was_sister` | 기록 사진 속 이전 근무자가 실종된 언니임을 확인 |
| 5 | `story.sister_investigated_disappearance` | 언니가 호텔의 실종 소문을 추적했다는 흔적 |
| 6 | `story.do_not_say_looking_for_sibling` | `동생을 찾으러 왔다고 말하지 마`라는 언니의 문장 |
| 7 | `story.younger_sister_recognition` | 플레이어가 바로 그 동생이라는 인식 |

한국어·영어 문장은 `story.day.{day}.line.{line}` locale key로 분리한다. 기본 언어는 한국어이고 영어는 누락 key의 fallback이자 선택 가능한 locale이다.

## 도입 흐름

### 1. 밀린 임금 전화

- 발신자는 자기 정체와 관리자의 얼굴을 공개하지 않는다.
- 목적은 `"호텔에 와서 밀린 돈을 받아 가라"`는 제안과 근무 수락 동기를 만드는 것이다.
- 플레이어가 전화번호를 어떻게 알았는지 묻더라도 즉시 설명하지 않는다.
- 선택지로 근무를 거절해 본편을 중단시키지 않는다. 빚 압박을 보여 준 뒤 수락으로 진행한다.

### 2. 첫 근무 기록

- 호텔에 도착한 플레이어는 자신의 이름으로 된 이전 근무 기록을 발견한다.
- 기록에는 연락처가 두 개 있다는 사실을 확인할 수 있어야 한다.
- 두 번째 번호의 끝자리 또는 전체 번호가 현재 플레이어 번호와 일치한다.
- 이 시점에는 “언니가 썼다”는 설명 문구 대신 필체, 날짜와 소지한 단서를 통해 의심하게 한다.

### 3. 언니의 명의 사용 확인

- 이후 단서에서 이전 근무자가 언니였음을 확인한다.
- 언니가 단순히 임금을 받기 위해 사칭한 것이 아니라 동생의 실종·납치 이야기를 조사하려 했다는 목적을 분리해서 공개한다.
- 언니의 메모가 룰북의 규칙 출처처럼 보이게 만들지 않는다. 룰북은 끝까지 관리자가 만든다.

### 4. 모순 문장

> 동생을 찾으러 왔다고 말하지 마

- 일반 시스템 경고가 아니라 이야기 단서로 한 번 강조한다.
- UI가 의미를 풀이해 주지 않는다.
- 플레이어가 “동생은 나인데?”라고 스스로 연결할 수 있도록 바로 앞이나 뒤에 과도한 해설을 붙이지 않는다.

정확한 Day와 현재 대화형 전달 순서는 위 표로 확정해 `HotelStoryDeliveryManager.DAY_BEATS`에서 관리한다. 전달 매체를 나중에 전화·기록지·사진으로 교체할 때도 beat ID와 Day 순서는 유지한다.

## 현재 데이터 계약

스토리 전달은 `main.gd`의 날짜 분기에 문장을 직접 넣지 않고 `scripts/story/story_delivery_manager.gd`의 Day별 beat 데이터로 관리한다.

```text
id
content_key
fallback_content
```

예시 ID:

```text
story.unpaid_wages_call
story.debt_forces_acceptance
story.previous_shift_under_player_name
story.second_contact_matches_player
story.previous_worker_was_sister
story.sister_investigated_disappearance
story.do_not_say_looking_for_sibling
story.younger_sister_recognition
```

텍스트와 음성은 beat ID를 유지한 채 locale별 자산만 교체한다. 컷신을 나중에 이미지·영상으로 바꿔도 완료 beat와 진행 step은 그대로 둔다.

## 저장과 재생

저장할 상태:

```text
completed_story_beat_ids
unlocked_evidence_ids
current_story_sequence_id
story_sequence_step
```

- 같은 통화나 핵심 문장을 로드할 때 반복하지 않는다.
- sequence 도중 저장하면 처음부터 다시 재생하지 않고 안전한 step 경계에서 복구한다.
- Day를 다시 시작해도 이미 확인한 증거는 사라지지 않는다.
- meta collection에 넣을지는 별도 결정 전까지 day save 안에서만 관리한다.

## 룰북과 관리자의 분리

- 룰북 페이지의 작성자는 관리자다.
- 언니가 남긴 단서는 일반 메모, 근무 기록 또는 다른 inspectable asset으로 분리한다.
- 룰북은 Day 1의 정상 규칙 1~3개로 시작하고 이후 수상한 규칙이 이미지 페이지에 추가된다.
- 관리자의 초상, 실명, 실제 통화 목소리 소유자는 확정 전 생성하지 않는다.
- 규칙의 문체와 언니 단서의 필체·문체가 시각적으로 구분돼야 한다.

## 제작 자산

| 자산 | 형태 | 교체 계약 |
| --- | --- | --- |
| 도입 전화 | locale별 음성 또는 자막 sequence | beat ID 유지 |
| 이전 근무 기록 | 프런트 inspectable full-screen 이미지 | 텍스트 fallback 유지 |
| 두 연락처 기록 | 근무 기록의 확대 영역 또는 별도 inspectable | 번호 데이터는 locale과 분리 |
| 언니의 단서 | 실제 종이 촬영본으로 교체 가능한 이미지 | 룰북 경로와 분리 |
| 룰북 Day 1~7 | locale별 페이지 이미지 | 기존 page catalog fallback |
| 핵심 문장 | story beat presentation | 일반 anomaly 경고 UI를 사용하지 않음 |

SceneLock를 사용할 때 기록지 전체 글자를 생성형 모델에 맡기지 않는다. 빈 종이 질감과 조명만 생성·보정한 뒤 검수한 실제 한글 필기 또는 text layer를 합성한다.

## QA

- 플레이어와 이전 근무자를 같은 인물로 오해시키는 UI 화자 표기가 없는지 확인
- 연락처가 두 개이고 두 번째가 플레이어 번호라는 단서가 실제 화면에서 읽히는지 확인
- 언니가 호텔에서 일한 이유가 동생 조사였다는 사실을 임금 문제와 혼동하지 않는지 확인
- 관리자 정체가 임의의 얼굴·이름·귀신으로 확정되지 않았는지 확인
- 언니 메모와 관리자 룰북이 시각·데이터 경로 모두 분리됐는지 확인
- 핵심 문장 직후 `"동생은 당신이다"` 같은 해설이 나오지 않는지 확인
- 새 게임, 저장·로드와 Day 재시작에서 핵심 beat가 중복 재생되지 않는지 확인
