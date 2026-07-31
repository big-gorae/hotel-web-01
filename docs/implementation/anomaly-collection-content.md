# 이상현상 모음 콘텐츠 편집 가이드

이상현상 모음에 표시되는 제목과 본문은 런타임 로직과 분리해
`scripts/horror/anomaly_collection_content.gd` 한 파일에서 관리한다.

## 항목 수정

`ENTRIES`에서 이벤트 ID를 찾은 뒤 다음 값만 수정한다.

- `TYPE_ENTITY`: 카드에 `스토리`를 표시하는 엔티티
- `TYPE_PHENOMENON`: 카드에 `현상 설명`을 표시하는 기현상
- `en_title`, `en_body`: 영어 제목과 본문이자 다른 언어의 기본 fallback
- `ko_title`, `ko_body`: 한국어 제목과 본문

본문은 UI에 맞춰 별도 줄바꿈 문자를 넣지 않아도 자동으로 줄바꿈된다. 정사와 모순되지
않도록 엔티티 스토리는 `docs/anomaly-bible/entities`, 기현상 설명은
`docs/anomaly-bible/phenomena`의 확정 내용을 기준으로 수정한다.

## 언어 추가

각 항목의 `copy` 사전에 `ja`, `ru`, `zh`처럼 `HotelLocalization.LANGUAGE_CODES`와 같은
locale 코드를 추가하면 기존 다국어 전환에 자동으로 연결된다. 해당 locale이 없는 항목은
기존 다국어 정책과 동일하게 영어 본문으로 fallback한다.

새 이상현상을 카탈로그에 등록할 때는 같은 이벤트 ID의 `ENTRIES` 항목도 반드시 추가한다.
단위 테스트가 모든 카탈로그 항목에 제목, 본문과 정사 분류가 있는지 검사한다.
