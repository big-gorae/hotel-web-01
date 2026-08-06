class_name HotelSceneLocalizationContent
extends RefCounted

## Player-facing scene and hotspot copy lives here so Korean and English stay
## editable without changing scene geometry or interaction logic.

const SceneCatalog := preload("res://scripts/scenes/hotel_scene_catalog.gd")

const SCENE_KO := {
	"front_desk": {"title": "프런트", "intro": "야간 프런트 카운터는 조용하다. 메모와 전화기, 숙박부가 단서를 기다리고 있다."},
	"corridor": {"title": "복도", "intro": "외부 복도는 축축하고 어둡다. 번호가 붙은 문마다 서로 다른 단서가 숨어 있을 수 있다."},
	"laundry_room": {"title": "세탁실", "intro": "형광등 아래 세탁실에서 낮은 기계음이 울린다. 벽을 따라 세탁기가 늘어서 있고 출구는 뒤쪽이다."},
	"exterior_stairs": {"title": "외부 계단", "intro": "외부 계단이 모텔 벽을 가로지른다. 아래로 젖은 아스팔트가 펼쳐져 있다."},
	"room_105_door_window": {"title": "105호", "intro": "커튼이 반쯤 닫힌 소박한 객실이다. 침대와 창문, 문이 눈에 들어온다."},
	"room_105_bathroom_entry": {"title": "105호", "intro": "이 각도에서는 욕실과 옷장문, TV와 침대가 한눈에 들어온다."},
	"room_105_bathroom": {"title": "105호 욕실", "intro": "욕실은 비좁고 밝다. 거울과 세면대, 욕조와 문이 다닥다닥 붙어 있다."},
	"room_106_bed_bathroom_entry": {"title": "106호", "intro": "106호에서는 침대와 창문, 욕실 입구와 서랍장이 잘 보인다."},
	"room_106_bathroom": {"title": "106호 욕실", "intro": "106호 욕실은 다른 객실과 같은 구조다. 거울과 세면대, 욕조와 문이 가까이 붙어 있다."},
	"room_107_bed_nightstand": {"title": "107호", "intro": "107호에는 협탁과 전화기, 흐트러진 침대가 보인다."},
	"room_107_bathroom_entry": {"title": "107호", "intro": "107호의 다른 각도에서는 욕실 입구와 옷장문이 보인다."},
	"room_107_bathroom": {"title": "107호 욕실", "intro": "107호 욕실은 다른 객실과 같은 구조다. 거울과 세면대, 욕조와 문이 가까이 붙어 있다."},
	"room_108_bed_window": {"title": "108호", "intro": "108호에 들어서면 침대와 창문, 책상 쪽이 먼저 보인다."},
	"room_108_bathroom_entry": {"title": "108호", "intro": "이 각도에서는 욕실 입구와 서랍장, TV와 침대가 모두 보인다."},
	"room_108_bathroom": {"title": "108호 욕실", "intro": "108호 욕실은 다른 객실과 같은 구조다. 거울과 세면대, 욕조와 문이 가까이 붙어 있다."},
}

const LABEL_KO := {
	"Front Desk": "프런트",
	"Corridor": "복도",
	"Laundry Room": "세탁실",
	"Laundry": "세탁실",
	"Exterior Stairs": "외부 계단",
	"Stairs": "계단",
	"Room 105": "105호",
	"Room 105 Bathroom Entry": "105호 욕실 입구",
	"Room 105 Bathroom": "105호 욕실",
	"Room 106": "106호",
	"Room 106 Bathroom": "106호 욕실",
	"Room 107": "107호",
	"Room 107 Bathroom Entry": "107호 욕실 입구",
	"Room 107 Bathroom": "107호 욕실",
	"Room 108": "108호",
	"Room 108 Bathroom Entry": "108호 욕실 입구",
	"Room 108 Bathroom": "108호 욕실",
	"Lights": "조명",
	"Bell": "벨",
	"Phone": "전화기",
	"Logbook": "숙박부",
	"Exit Door": "출입문",
	"Exit": "나가기",
	"Washer": "세탁기",
	"Rules": "규칙",
	"Detergent": "세제",
	"Door": "문",
	"Mirror": "거울",
	"Sink": "세면대",
	"Tub": "욕조",
	"Turn": "돌아보기",
	"Bathroom": "욕실",
	"Closet": "옷장",
	"TV": "TV",
	"Nightstand": "협탁",
	"Window": "창문",
	"Lamp": "스탠드",
	"Bed": "침대",
	"Papers": "종이",
	"Dresser": "서랍장",
	"Room 109": "109호",
	"Child": "아이",
	"Cute Doll": "귀여운 목각 인형",
	"Hanging Wooden Girl": "목을 맨 목각 여자 인형",
}

const HOTSPOT_LABELS := {
	"corridor": {
		"corridor_left_edge": "Front Desk", "corridor_bottom_edge": "Stairs",
		"room_105": "Room 105", "room_106": "Room 106", "room_107": "Room 107", "room_108": "Room 108",
		"walkway_lights": "Lights", "room_109_locked_door": "Room 109", "room_109_open_door": "Room 109",
	},
	"exterior_stairs": {"stairs_right_edge": "Corridor", "metal_stairs": "Stairs"},
	"front_desk": {
		"front_left_edge": "Laundry", "front_right_edge": "Corridor", "desk_bell": "Bell",
		"phone": "Phone", "logbook": "Logbook", "front_door": "Exit Door",
	},
	"laundry_room": {
		"laundry_bottom_edge": "Exit", "laundry_second_washer": "Washer", "laundry_rules": "Rules",
		"detergent": "Detergent", "anomaly_pickup:hanging_girl_doll": "Cute Doll",
	},
	"room_105_bathroom": {
		"bathroom_door": "Door", "bathroom_mirror": "Mirror", "bathroom_sink": "Sink", "bathroom_tub": "Tub",
	},
	"room_105_bathroom_entry": {
		"bathroom_left_edge": "Turn", "bathroom_right_edge": "Turn", "bathroom_sink": "Bathroom",
		"closet_door": "Closet", "television": "TV", "nightstand": "Nightstand",
	},
	"room_105_door_window": {
		"room_right_edge": "Turn", "room_door": "Door", "window": "Window", "lamp": "Lamp",
	},
	"room_106_bathroom": {
		"room_106_bathroom_door": "Door", "room_106_bathroom_mirror": "Mirror",
		"room_106_bathroom_sink": "Sink", "room_106_bathroom_tub": "Tub",
	},
	"room_106_bed_bathroom_entry": {
		"room_106_exit_edge": "Corridor", "room_106_bed": "Bed", "room_106_window": "Window",
		"room_106_bathroom_entry": "Bathroom",
	},
	"room_107_bathroom": {
		"room_107_bathroom_door": "Door", "room_107_bathroom_mirror": "Mirror",
		"room_107_bathroom_sink": "Sink", "room_107_bathroom_tub": "Tub",
	},
	"room_107_bathroom_entry": {
		"room_107_left_edge": "Turn", "room_107_bathroom_doorway": "Bathroom",
		"room_107_closet_door": "Closet", "room_107_phone": "Phone",
	},
	"room_107_bed_nightstand": {
		"room_107_turn_edge": "Turn", "room_107_door": "Door", "room_107_nightstand": "Nightstand",
		"room_107_window_view": "Window", "room_107_loose_papers": "Papers",
		"anomaly_choice:hanging_girl": "Hanging Wooden Girl",
	},
	"room_108_bathroom": {
		"room_108_bathroom_door": "Door", "room_108_bathroom_mirror": "Mirror",
		"room_108_bathroom_sink": "Sink", "room_108_bathroom_tub": "Tub",
	},
	"room_108_bathroom_entry": {
		"room_108_left_edge": "Turn", "room_108_bathroom_doorway": "Bathroom",
		"room_108_television": "TV", "room_108_dresser": "Dresser",
	},
	"room_108_bed_window": {
		"room_108_exit_edge": "Corridor", "room_108_right_edge": "Turn",
		"room_108_window": "Window", "room_108_nightstand": "Nightstand",
	},
}

const HOTSPOT_TEXTS := {
	"corridor.walkway_lights": ["The corridor lamps flicker at uneven intervals.", "복도 조명이 불규칙한 간격으로 깜박인다."],
	"corridor.room_109_open_door": ["The open doorway is too dark to judge its depth.", "열린 문 안쪽은 깊이를 가늠할 수 없을 만큼 어둡다."],
	"exterior_stairs.metal_stairs": ["The metal stairs creak under light pressure.", "금속 계단은 가볍게 디디기만 해도 삐걱거린다."],
	"front_desk.desk_bell": ["The bell gives a thin ring that hangs in the lobby for a second.", "벨의 가느다란 울림이 잠시 로비에 걸려 있다."],
	"front_desk.phone": ["The desk phone still works. Its display is blank.", "프런트 전화기는 아직 작동한다. 표시창은 비어 있다."],
	"front_desk.logbook": ["Guest names, room numbers, and a few rushed pencil marks fill the page.", "페이지에는 투숙객 이름과 객실 번호, 급히 휘갈긴 연필 자국이 가득하다."],
	"front_desk.front_door": ["The glass door looks out toward the corridor, but this is not the way you leave the desk.", "유리문 너머로 복도가 보이지만 프런트에서 나가는 길은 이쪽이 아니다."],
	"laundry_room.laundry_rules": ["Laundry rules are posted beside the window in small print.", "창문 옆에 세탁 규칙이 작은 글씨로 붙어 있다."],
	"laundry_room.detergent": ["Detergent bottles sit near the sink, lined up like someone left in a hurry.", "누군가 급히 떠난 듯 세제 통이 세면대 옆에 줄지어 놓여 있다."],
	"room_105_bathroom_entry.closet_door": ["The closet door is closed, but the knob is polished from frequent use.", "옷장문은 닫혀 있지만 손잡이는 자주 만진 듯 반들거린다."],
	"room_105_bathroom_entry.television": ["The television reflects the room back at you in a warped curve.", "TV 화면이 방 안을 일그러진 곡면으로 비춘다."],
	"room_105_bathroom_entry.nightstand": ["A phone sits beside the bed. The room card is missing.", "침대 옆에 전화기가 놓여 있다. 객실 카드는 보이지 않는다."],
	"room_105_door_window.window": ["The window faces the motel exterior. The glass is cold to the touch.", "창문은 모텔 바깥을 향해 있다. 유리는 손에 차갑게 닿는다."],
	"room_105_door_window.lamp": ["The lamp is warm, making the room feel smaller than it is.", "스탠드의 온기가 방을 실제보다 더 좁게 느껴지게 한다."],
	"room_106_bed_bathroom_entry.room_106_bed": ["The bedspread is pulled into place, but the room still feels recently used.", "침대보는 가지런히 당겨져 있지만 방에는 방금까지 누군가 있던 기척이 남아 있다."],
	"room_106_bed_bathroom_entry.room_106_window": ["The curtains leave a narrow view of the outside lights.", "커튼 틈으로 바깥 불빛이 좁게 보인다."],
	"room_107_bathroom_entry.room_107_closet_door": ["The door beside the bathroom is a closet, not the exit.", "욕실 옆 문은 출구가 아니라 옷장문이다."],
	"room_107_bathroom_entry.room_107_phone": ["The phone is close enough to reach from the pillow.", "베개에 누운 채로도 닿을 만큼 전화기가 가깝다."],
	"room_107_bed_nightstand.room_107_nightstand": ["The room phone sits beside a loose note and a warm lamp.", "객실 전화기가 흩어진 메모와 따뜻한 스탠드 옆에 놓여 있다."],
	"room_107_bed_nightstand.room_107_window_view": ["A parked car is visible through the window.", "창문 너머로 주차된 차 한 대가 보인다."],
	"room_107_bed_nightstand.room_107_loose_papers": ["A few papers lie on the carpet near the bed.", "침대 옆 카펫에 종이 몇 장이 떨어져 있다."],
	"room_108_bathroom_entry.room_108_television": ["The television is mounted high on the wall beside the bathroom entry.", "TV가 욕실 입구 옆 벽 높은 곳에 걸려 있다."],
	"room_108_bathroom_entry.room_108_dresser": ["The dresser blocks most of the path along the right wall.", "서랍장이 오른쪽 벽을 따라 난 길 대부분을 막고 있다."],
	"room_108_bed_window.room_108_window": ["The opposite wing of the hotel is visible through the window.", "창문 너머로 호텔 반대편 동이 보인다."],
	"room_108_bed_window.room_108_nightstand": ["A lamp and a small notepad sit beside the bed.", "침대 옆에 스탠드와 작은 메모장이 놓여 있다."],
}

const SHARED_BATHROOM_TEXTS := {
	"mirror": ["The mirror is worn at the edges, blurring the room behind you.", "거울 가장자리가 닳아 등 뒤의 방을 흐릿하게 비춘다."],
	"sink": ["A small tube rests near the sink. The counter is stained from years of use.", "세면대 옆에 작은 튜브가 놓여 있다. 상판에는 오랜 사용으로 얼룩이 배어 있다."],
	"tub": ["The shower curtain hangs still. The tub is dry.", "샤워 커튼은 움직이지 않는다. 욕조는 말라 있다."],
}


static func append_translations(localization_tables: Dictionary, english_language: int, korean_language: int) -> void:
	var english: Dictionary = localization_tables.get(english_language, {})
	var korean: Dictionary = localization_tables.get(korean_language, {})
	english["hotspot.common.shower_curtain.label"] = "Shower Curtain"
	english["hotspot.common.shower_curtain.open"] = "Open the shower curtain."
	english["hotspot.common.shower_curtain.close"] = "Close the shower curtain."
	korean["hotspot.common.shower_curtain.label"] = "샤워 커튼"
	korean["hotspot.common.shower_curtain.open"] = "샤워 커튼을 연다."
	korean["hotspot.common.shower_curtain.close"] = "샤워 커튼을 닫는다."
	english["hotspot.corridor.room_109_locked_door.notice"] = "A 'Do not disturb' sign is hanging from the handle."
	korean["hotspot.corridor.room_109_locked_door.notice"] = "'Do not disturb'가 걸려 있다"
	for scene_id in SceneCatalog.SCENES:
		var scene: Dictionary = SceneCatalog.SCENES[scene_id]
		var korean_scene: Dictionary = SCENE_KO.get(scene_id, {})
		english["scene.%s.title" % scene_id] = String(scene.get("title", ""))
		english["scene.%s.intro" % scene_id] = String(scene.get("intro", ""))
		korean["scene.%s.title" % scene_id] = String(korean_scene.get("title", ""))
		korean["scene.%s.intro" % scene_id] = String(korean_scene.get("intro", ""))
		for exit_data in scene.get("exits", []):
			var target := String(exit_data.get("target", ""))
			var label := String(exit_data.get("label", ""))
			var key := "exit.%s.%s.label" % [scene_id, target]
			english[key] = label
			korean[key] = String(LABEL_KO.get(label, ""))

	for scene_id in HOTSPOT_LABELS:
		for hotspot_id in HOTSPOT_LABELS[scene_id]:
			var label := String(HOTSPOT_LABELS[scene_id][hotspot_id])
			var key := "hotspot.%s.%s.label" % [scene_id, hotspot_id]
			english[key] = label
			korean[key] = String(LABEL_KO.get(label, ""))

	for compound_id in HOTSPOT_TEXTS:
		_append_hotspot_text(compound_id, HOTSPOT_TEXTS[compound_id], english, korean)

	for room_number in range(105, 109):
		var scene_id := "room_%d_bathroom" % room_number
		for kind in SHARED_BATHROOM_TEXTS:
			var hotspot_id := "bathroom_%s" % kind if room_number == 105 else "room_%d_bathroom_%s" % [room_number, kind]
			_append_hotspot_text("%s.%s" % [scene_id, hotspot_id], SHARED_BATHROOM_TEXTS[kind], english, korean)

	localization_tables[english_language] = english
	localization_tables[korean_language] = korean


static func _append_hotspot_text(compound_id: String, copies: Array, english: Dictionary, korean: Dictionary) -> void:
	var separator := compound_id.find(".")
	var scene_id := compound_id.left(separator)
	var hotspot_id := compound_id.substr(separator + 1)
	var key := "hotspot.%s.%s.text" % [scene_id, hotspot_id]
	english[key] = String(copies[0])
	korean[key] = String(copies[1])
