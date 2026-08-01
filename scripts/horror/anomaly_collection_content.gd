class_name HotelAnomalyCollectionContent
extends RefCounted

## Collection copy lives here so story edits do not require touching runtime logic.
## Add a locale beside `en`/`ko` to translate an entry; missing locales use English.

const TYPE_ENTITY := "entity"
const TYPE_PHENOMENON := "phenomenon"

static var ENTRIES := {
	"room_105_closet_pig_man": _entry(TYPE_ENTITY,
		"Closet Pig-Mask Man",
		"A man in a pale pig mask slowly forces open the wardrobe in Room 105. Hold the door shut long enough to push him back into the dark.",
		"옷장의 돼지 가면 남자",
		"창백한 돼지 가면을 쓴 남자가 105호 옷장을 아주 천천히 밀어 연다. 문을 계속 눌러 어둠 속으로 밀어 넣어야 한다."),
	"room_106_abandoned_child": _entry(TYPE_ENTITY,
		"The Unregistered Child",
		"A child born and abandoned in the hotel was never entered in the guest register. It attacks anyone who repeats its mother's betrayal, while a false image of that mother waits only in the bathroom where she died.",
		"등록되지 않은 아이",
		"호텔에서 태어나 버려진 아이는 숙박부에 한 번도 등록되지 못했다. 아이는 자신을 버린 어머니의 행동을 되풀이하는 사람을 공격하고, 어머니가 죽은 화장실에는 진짜가 아닌 어머니의 형상만 남아 있다."),
	"room_108_light_repair_call": _entry(TYPE_ENTITY,
		"The Unanswered Call",
		"The front-desk phone must be answered before the thirteenth ring, but the caller's invitation must never be obeyed. Answering keeps it at a distance; entering the room it names lets the voice step out of the receiver.",
		"받지 못한 전화",
		"프런트 전화는 열세 번째 벨이 울리기 전에 받아야 하지만, 수화기 속 존재가 부르는 객실에는 들어가면 안 된다. 전화를 받으면 거리를 벌 수 있지만 지시를 따르면 목소리가 수화기 밖으로 나온다."),
	"laundry_red_washer": _entry(TYPE_ENTITY,
		"The Red Washer",
		"Something hidden among the laundry turns the washer glass red without changing its ordinary rhythm. The completion music is not a sign of safety, but a ritual that holds the watcher in the laundry room until the unseen load can be discarded.",
		"붉은 세탁기",
		"빨랫감 속에 숨은 무언가가 평범한 회전 속도를 유지한 채 세탁기 유리를 붉게 물들인다. 완료 음악은 안전 신호가 아니라, 보이지 않는 빨래를 버릴 때까지 목격자를 세탁실에 붙잡아 두는 의식에 가깝다."),
	"room_109_open_door": _entry(TYPE_ENTITY,
		"The Open Door of Room 109",
		"From the third night onward, an open door waits where no one should look inside. On the final night the rule reverses: the door must be left open, and whatever passes behind the worker must be allowed to leave without being seen.",
		"109호의 열린 문",
		"세 번째 밤부터 누구도 들여다보면 안 되는 열린 문이 복도에서 기다린다. 마지막 밤에는 규칙이 뒤집혀 문을 열어 두어야 하며, 직원의 뒤를 지나가는 존재를 보지 않은 채 내보내야 한다."),
	"room_109_day7_passage": _entry(TYPE_ENTITY,
		"The Passage from Room 109",
		"On the final night, the door that once demanded avoidance must be held open. The footsteps behind the worker belong to something leaving the hotel, and turning around would make it stay.",
		"109호에서 나가는 것",
		"마지막 밤에는 한때 피해야 했던 문을 직접 열어 두어야 한다. 직원의 뒤에서 이어지는 발소리는 호텔을 떠나는 존재의 것이며, 뒤돌아보는 순간 그것은 다시 머물게 된다."),
	"vacant_room_blanket_child": _entry(TYPE_ENTITY,
		"The Child Under the Blanket",
		"A vacant-room blanket rises in the shape of a small child, laughing more harshly the longer it is ignored. It must never be uncovered; only a watcher who closes their eyes and waits in the room can make the bed lie flat again.",
		"이불 속 아이",
		"비어 있는 객실의 이불이 작은 아이의 형상으로 솟아 있고, 외면하는 시간이 길수록 웃음은 거칠어진다. 이불을 걷어 확인해서는 안 되며, 같은 방에서 눈을 감고 기다린 사람만 침대를 다시 평평하게 만들 수 있다."),
	"hotel_following_shadow": _entry(TYPE_ENTITY,
		"The Following Shadow",
		"An invisible presence repeats each footstep and opening door after a fixed delay. Rapid bell strikes make it reveal its pain; only then can the worker run room to room until the copied footsteps finally fall away.",
		"따라오는 그림자",
		"보이지 않는 존재가 일정한 간격을 두고 직원의 발소리와 문 여는 소리를 그대로 따라 한다. 프런트 벨을 빠르게 연타해 고통을 드러내게 한 뒤 여러 방을 오가야 복제된 발소리가 마침내 떨어져 나간다."),
	"room_107_hanging_girl": _entry(TYPE_ENTITY,
		"The Hanged Wooden Girl",
		"A wooden girl hanging in Room 107 calls death her dangle-dangle game and asks the worker to join. She rejects every diversion except a companion of her own: the little wooden doll she calls Walter.",
		"목을 맨 목각 여자 인형",
		"107호에 목을 맨 목각 여자 인형은 죽음을 ‘데롱데롱 놀이’라 부르며 직원에게 함께하자고 권한다. 다른 놀이는 모두 거부하지만, 자신과 같은 작은 목각 인형 ‘윌터’를 친구로 건네면 잠시 만족한다."),

	"front_monitor_ghost": _entry(TYPE_PHENOMENON, "Figure in the Monitor", "A still upper-body silhouette occupies the dark front-desk monitor as though the screen were reflecting someone who is not in the room.", "모니터 속 귀신 형상", "프런트의 검은 모니터에 방 안에는 없는 상반신 형상이 비친 듯 흐릿하고 움직이지 않은 채 서 있다."),
	"front_glass_face": _entry(TYPE_PHENOMENON, "Face Beyond the Glass", "Half a face remains fixed beyond the front glass door, changing only into a crueler expression after the first rapid sequence of bell strikes.", "유리문 너머의 얼굴", "프런트 유리문 프레임 너머로 얼굴 절반이 같은 자리에 붙어 있고, 첫 번째 벨 연타 뒤에만 더 악독한 표정으로 변한다."),
	"front_die_sign": _entry(TYPE_PHENOMENON, "The Death Sign", "The front-desk notice has already been replaced by a single rough word written in red: DIE.", "‘죽어’라고 적힌 안내판", "정상 문구가 있어야 할 프런트 안내판이 붉고 거친 글씨로 적힌 ‘죽어’ 한마디로 바뀌어 있다."),
	"corridor_red_room_light": _entry(TYPE_PHENOMENON, "Red Room Light", "One corridor room light burns vivid red, staining the nearby wall and door while the room itself remains unchanged.", "빨간색 객실등", "복도의 객실등 하나만 선명한 적색으로 변해 벽과 문 아래를 물들이지만 객실 안에는 아무 변화가 없다."),
	"corridor_blood_puddle": _entry(TYPE_PHENOMENON, "Blood Beneath the Door", "Dark blood has seeped from beneath a closed guest-room door into a shallow puddle, yet opening the room reveals no source.", "문 아래 피 웅덩이", "닫힌 객실 문 아래에서 검붉은 피가 얕은 웅덩이로 흘러나왔지만, 문을 열어도 객실 안에서는 원인을 찾을 수 없다."),
	"laundry_baby_face_surfaces": _entry(TYPE_PHENOMENON, "Baby-Face Wallpaper", "Tormented baby faces cover the laundry-room floor, ceiling, and every wall, all sharing the same open or closed eyes.", "아기 얼굴 벽지", "세탁실의 바닥과 천장, 모든 벽이 괴로워하는 아기 얼굴로 뒤덮이고 각 면의 수많은 눈이 하나의 상태를 공유한다."),
	"room_107_human_skin_towel": _entry(TYPE_PHENOMENON, "Human-Skin Towel", "A wet sheet of recognizably human skin hangs neatly folded where a clean towel should be, without a face or complete body part.", "수건 대신 걸린 인간 가죽", "깨끗한 수건이 있어야 할 자리에 얼굴이나 온전한 신체 부위가 없는 젖은 인간 가죽 한 장이 가지런히 걸려 있다."),
	"stairs_hell_arrow": _entry(TYPE_PHENOMENON, "Exit Arrow to Hell", "The emergency sign burns an impossible red and points down toward a staircase whose end has become solid darkness.", "지옥으로 향하는 비상 화살표", "비상 유도등이 불가능할 만큼 붉게 타오르며 끝이 검은 어둠으로 막힌 외부 계단 아래를 가리킨다."),
	"room_105_grotesque_portrait": _entry(TYPE_PHENOMENON, "Grotesque Portrait", "An ordinary framed picture has become a motionless face with melting skin and a mouth opened beyond human anatomy.", "끔찍한 얼굴이 그려진 액자", "평범했던 액자가 피부가 흘러내리고 입이 사람의 형태를 벗어나도록 벌어진 움직이지 않는 얼굴 그림으로 변해 있다."),
	"room_108_tv_ghost": _entry(TYPE_PHENOMENON, "Figure in the Television", "A figure absent from the room appears inside the switched-off television, its expression turning more vicious as the screen is forced dark.", "TV에 비친 귀신 형상", "꺼져 있어야 할 TV에 방 안에는 없는 형상이 비치고, 화면을 끄려 할수록 표정이 더 악독하게 변한다."),
	"bathroom_shower_legs": _entry(TYPE_PHENOMENON, "The Closed Shower Curtain", "A shower curtain that should be open hides either an empty tub or the still legs of someone lying inside; each reopening may change the answer.", "닫힌 샤워 커튼과 다리", "열려 있어야 할 샤워 커튼이 욕조를 가리고 있으며, 다시 열 때마다 빈 욕조 또는 안에 누운 사람의 움직이지 않는 다리가 나타난다."),
	"room_107_empty_hanging_rope": _entry(TYPE_PHENOMENON, "The Empty Noose", "A noose sways faintly above a fallen chair in Room 107, holding no body or shadow and foreshadowing another visitor.", "빈 올가미가 걸린 방", "107호의 넘어진 의자 위에서 몸도 그림자도 매달지 않은 올가미가 미세하게 흔들리며 다른 방문자를 예고한다."),
	"room_105_bloody_handprint_mirror": _entry(TYPE_PHENOMENON, "Handprints Across the Mirror", "Red handprints of mismatched sizes cover every part of the bathroom mirror, reflecting neither a ghost nor the worker behind them.", "빨간 손자국으로 뒤덮인 거울", "크기가 제각각인 붉은 손자국이 욕실 거울을 빈틈없이 덮었지만 그 뒤에는 귀신도 직원의 모습도 비치지 않는다."),
	"room_106_horrific_mirror": _entry(TYPE_PHENOMENON, "The Ruined Bathroom in the Mirror", "The real bathroom remains clean while its mirror reflects a horribly ruined version of the same room, as though the damage exists only beyond the glass.", "끔찍한 화장실이 보이는 거울", "실제 욕실은 멀쩡하지만 거울 속에는 끔찍하게 훼손된 같은 공간이 비쳐, 파괴가 유리 너머에만 존재하는 듯 보인다."),
	"room_108_entrails_bathtub": _entry(TYPE_PHENOMENON, "Bathtub of Entrails", "The Room 108 bathtub is motionlessly packed with entrails and dark red water, with no visible source and no small mechanism to explain it.", "내장으로 가득한 욕조", "108호 욕조가 출처를 알 수 없는 내장과 검붉은 물로 움직임 없이 가득 차 있다."),
	"hell_mirror": _entry(TYPE_PHENOMENON, "Mirror of Hell", "A small mirror now contains the ruined bathroom that vanished from the larger glass. Its trapped screaming grows more dangerous the longer it is held.", "지옥의 거울", "큰 거울에서 사라진 끔찍한 화장실이 작은 거울 안으로 옮겨 붙었다. 손에 오래 들고 있을수록 갇힌 절규가 더 위험하게 커진다."),
}


static func has_entry(event_id: String) -> bool:
	return ENTRIES.has(event_id)


static func get_kind(event_id: String, fallback := TYPE_PHENOMENON) -> String:
	return String(ENTRIES.get(event_id, {}).get("kind", fallback))


static func get_copy(event_id: String, locale_code := "en") -> Dictionary:
	var entry: Dictionary = ENTRIES.get(event_id, {})
	var copies: Dictionary = entry.get("copy", {})
	return copies.get(locale_code, copies.get("en", {})).duplicate(true)


static func title_key(event_id: String) -> String:
	return "anomaly_collection.event.%s.title" % event_id


static func body_key(event_id: String) -> String:
	return "anomaly_collection.event.%s.body" % event_id


static func append_translations(localization_tables: Dictionary, language_codes: Dictionary) -> void:
	for language in language_codes:
		var locale_code: String = language_codes[language]
		var table: Dictionary = localization_tables.get(language, {})
		for event_id in ENTRIES:
			var copies: Dictionary = ENTRIES[event_id].get("copy", {})
			if not copies.has(locale_code):
				continue
			var copy: Dictionary = copies[locale_code]
			table[title_key(event_id)] = String(copy.get("title", ""))
			table[body_key(event_id)] = String(copy.get("body", ""))
		localization_tables[language] = table


static func apply_to_definition(definition) -> void:
	if definition == null or not ENTRIES.has(definition.id):
		return
	var english_copy := get_copy(definition.id)
	definition.collection_kind = get_kind(definition.id)
	definition.collection_title_key = title_key(definition.id)
	definition.collection_body_key = body_key(definition.id)
	definition.fallback_title = String(english_copy.get("title", definition.fallback_title))
	definition.fallback_description = String(english_copy.get("body", definition.fallback_description))


static func _entry(kind: String, en_title: String, en_body: String, ko_title: String, ko_body: String) -> Dictionary:
	return {
		"kind": kind,
		"copy": {
			"en": {"title": en_title, "body": en_body},
			"ko": {"title": ko_title, "body": ko_body},
		},
	}
