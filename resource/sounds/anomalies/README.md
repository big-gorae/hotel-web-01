# 이상현상 음향 교체 위치

최종 음향은 코드가 참조하는 고정 경로에 저장한다.

- `blanket_found_ja.ogg`: 이불 속 아이가 제한시간 종료 뒤 말하는 모든 언어 공통 일본어 음성. 현재 Kokoro `jf_alpha`로 생성한 `みーつけた。` 음성이 연결되어 있다.
- `baby_wallpaper_cry.ogg`: 아기 얼굴 벽지의 한 면을 처리할 때 재생하는 짧고 눌린 실제 아기 울음.
- `blanket_child_laugh_soft.ogg`: 이불 속 아이의 초기 실제 웃음.
- `blanket_child_laugh_distorted.ogg`: 같은 웃음을 저음으로 겹쳐 방치 후반에 사용하는 변조 상태.
- `shower_curtain_move.ogg`: 샤워 커튼을 열거나 닫을 때 재생하는 실제 천 마찰음.
- `curtain_legs_reveal.ogg`: 커튼 안의 다리를 최초로 발견할 때 한 번만 재생하는 낮은 마찰·충격 합성음.
- `shadow_footstep_sequence.ogg`: 플레이어의 세 걸음 이동음을 동일한 리듬으로 다시 재생하는 그림자 복제음.
- `front_glass_face_barn_owl_call.ogg`: 유리문 얼굴이 나타난 프런트 진입 시와 첫 벨 3연타 뒤 공격 상태로 바뀔 때, 같은 실제 가면올빼미 울음을 5ms 간격으로 세 번 연속 재생하는 시퀀스.

외부 녹음을 사용한 파일은 `resource/sounds/licenses/`에 원본 URL,
라이선스와 가공 내역을 기록한다. 상업 이용과 재배포가 허용된 CC0 또는
CC BY 4.0 원본만 사용한다.

파일이 누락되면 개발 빌드는 타이밍 검수용 합성음으로 fallback한다. fallback은 실제 일본어 발음이 아니며 최종 출시 자산으로 간주하지 않는다.

외부에서 받은 파일을 추가할 때는 `../licenses/`에 파일명, 원본 URL 또는 제작자, 라이선스, 수정 여부를 함께 기록한다.
