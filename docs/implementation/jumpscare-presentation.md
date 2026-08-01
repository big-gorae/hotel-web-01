# 점프스케어 연출

## 확정 시퀀스

1. 사망 판정과 같은 프레임에 대상 원본 이미지를 화면 전체에 `KEEP_ASPECT_COVER`로 표시한다.
2. 같은 프레임에 짧은 밝은 플래시, 고주파 충격음과 화면 진동을 시작한다. 페이드인은 사용하지 않는다.
3. 0.3초 동안 얼굴을 읽을 수 있게 두고 3.5%의 느린 전진과 작은 불규칙 진동만 적용한다.
4. 0.3초 시점에 붉은 플래시와 두 번째 저음 충격을 동기화하고, 0.13초 동안 지수 가속으로 2.05배까지 돌진시킨다.
5. 총 1.5초 뒤 기존 게임오버 흐름으로 복귀한다.

시각과 음향의 첫 충격을 동기화하고, 첫 충격 뒤 대상을 인지할 시간을 준 다음 두 번째 운동으로 예측을 깨는 구조다. 점프스케어를 자주 반복하면 둔감해지므로 실제 플레이에서는 엔티티 방치로 인한 사망 순간에만 사용한다.

## 원본 이미지 연결

| 이벤트 | 사용 이미지 |
| --- | --- |
| `room_105_closet_pig_man` | `res://resource/images/references/entities/room_105_closet_pig_mask_man/reference_pig_mask_01.png` · 화면 채우기 `Cover` · 초기 1.02배 · 0.15초 후 돌진 |
| `room_106_abandoned_child` | `res://resource/images/references/entities/room_106_fake_mother/reference_face_01.png` · 원본 비율 유지 `Contain` · 초기 1.02배 · 0.25초 후 돌진 |

두 이미지는 생성형 재해석이나 SceneLock 재합성 없이 승인된 원본을 런타임에서 직접 읽는다. 얼굴이 돌진 중 화면 밖으로 빠지지 않도록 이벤트마다 별도의 확대 중심점을 갖는다.

다른 엔티티도 승인된 원본이 생기면 `HotelHorrorCatalog.JUMPSCARE_IMAGE_BY_EVENT`와 `JUMPSCARE_FOCUS_BY_EVENT`에 추가한다. 원본이 없는 이벤트는 현재 텍스트 플레이스홀더를 유지한다.

## 음향 확장

현재 모든 이미지 점프스케어는 `shared_shock_v1`을 사용한다. 이 스트림은 첫 프레임의 노이즈 충격·상승하는 비명 성분과 설정된 돌진 시작 시점의 저음 충격을 하나로 합성한다.

`HotelHorrorEventDefinition.jumpscare_audio_path`에 엔티티 전용 음원을 지정하면 공용 스트림 대신 해당 파일을 재생할 수 있다. 따라서 시각 타이밍을 바꾸지 않고 엔티티별 소리를 교체할 수 있다.

## 프리뷰

Godot 에디터 실행 또는 `HOTEL_DEBUG_UI=1` 환경에서 상단 디버그 패널의 `⚡ 점프스케어 연구소`를 연다. 연구소에서는 다음 값을 엔티티별로 조절하고 `현재 값으로 프리뷰`할 수 있다.

- 원본 맞춤: 화면 채우기 `Cover` 또는 원본 비율 `Contain`
- 돌진 시작 시점과 처음 나타나는 원본 사진의 확대
- 돌진에 걸리는 시간과 최종 확대
- 전체 연출 길이
- 확대 중심 X/Y
- 첫 충격과 돌진의 화면 진동
- 프리뷰 충격음 음량

연구소 변경값은 프리뷰 복사본에만 적용된다. 컬렉션, 사망 판정, 원본 이벤트 정의와 저장 데이터는 변경하지 않는다.

## 조사 근거

- GDC 2015, [The Neuroscience of Game Audio](https://www.gdcvault.com/play/1022315/The-Neuroscience-of-Game): 시청각 반응시간, startle circuit과 동기화 품질을 연출 근거로 사용했다.
- GDC 2019, [Adapting Linear Audio Techniques to Improve Voyeurism and Emotional Engagement in Horror Games](https://www.gdcvault.com/play/1026010/Adapting-Linear-Audio-Techniques-to): 핵심 순간에 선형 음향을 정밀하게 맞추는 방식을 반영했다.
- Game Developer, [The time and place for jump scares, according to horror devs](https://www.gamedeveloper.com/design/the-time-and-place-for-jump-scares-according-to-horror-devs): 반복보다 드문 사망 결과로 제한하는 판단에 반영했다.
