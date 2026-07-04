class_name HotelLocalization
extends RefCounted

enum Language {
	ENGLISH,
	KOREAN,
	JAPANESE,
	RUSSIAN,
	CHINESE,
}

const DEFAULT_LANGUAGE := Language.ENGLISH
const SUPPORTED_LANGUAGES := [
	Language.ENGLISH,
	Language.KOREAN,
	Language.JAPANESE,
	Language.RUSSIAN,
	Language.CHINESE,
]
const LANGUAGE_CODES := {
	Language.ENGLISH: "en",
	Language.KOREAN: "ko",
	Language.JAPANESE: "ja",
	Language.RUSSIAN: "ru",
	Language.CHINESE: "zh",
}

var current_language := DEFAULT_LANGUAGE
var translations := {
	Language.ENGLISH: {
		"ui.menu.title": "Menu",
		"ui.menu.continue": "Continue",
		"ui.menu.inventory": "Inventory",
		"ui.menu.rule_book": "Rule Book",
		"ui.menu.brightness": "Brightness",
		"ui.menu.quit": "Quit",
		"ui.inventory.title": "Inventory",
		"ui.inventory.hint": "Drag an item to Hand to equip it.",
		"ui.inventory.empty": "No items yet.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "Drag item here",
		"ui.equipment.empty": "Empty",
		"ui.equipment.tooltip": "Open inventory",
		"ui.rule_book.title": "Rule Book",
		"ui.rule_book.subtitle": "Hotel night rules",
		"ui.rule_book.rule.1": "If the front desk bell rings twice, do not answer the second ring.",
		"ui.rule_book.rule.2": "Never enter a room whose number is missing from the corridor door.",
		"ui.rule_book.rule.3": "If the laundry room washer closes by itself, leave before the third footstep.",
		"ui.rule_book.rule.4": "When a guest asks for Room 108, check whether their reflection is present first.",
		"ui.rule_book.rule.5": "Do not follow voices coming from the exterior stairs after midnight.",
		"ui.rule_book.rule.6": "If the bathroom light flickers three times, keep the door open until it stops.",
		"ui.rule_book.rule.7": "The hotel has no basement. If you see a basement sign, return to the front desk.",
		"ui.debug.hotspots.show": "Show click areas",
		"ui.debug.hotspots.hide": "Hide click areas",
		"ui.debug.dialogue.show": "Show dialogue panel",
		"ui.debug.dialogue.hide": "Hide dialogue panel",
		"ui.debug.navigation.show": "Show quick travel buttons",
		"ui.debug.navigation.hide": "Hide quick travel buttons",
		"item.room_105_key.name": "Room 105 Key",
		"item.room_105_key.description": "A worn brass key from the front desk drawer.",
		"item.small_flashlight.name": "Flashlight",
		"item.small_flashlight.description": "A compact flashlight. Useful when the power fails.",
		"item.guest_note.name": "Guest Note",
		"item.guest_note.description": "A folded note with a room number written in pencil.",
		"hotspot.laundry_room.laundry_second_washer.opened": "The second washer door is open.",
		"hotspot.laundry_room.laundry_second_washer.closed": "The second washer door is closed.",
	},
	Language.KOREAN: {
		"ui.menu.title": "메뉴",
		"ui.menu.continue": "계속하기",
		"ui.menu.inventory": "인벤토리",
		"ui.menu.rule_book": "룰 북",
		"ui.menu.brightness": "밝기",
		"ui.menu.quit": "종료",
		"ui.inventory.title": "인벤토리",
		"ui.inventory.hint": "아이템을 Hand로 드래그하면 장착됩니다.",
		"ui.inventory.empty": "아직 아이템이 없습니다.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "아이템을 여기에 놓기",
		"ui.equipment.empty": "비어 있음",
		"ui.equipment.tooltip": "인벤토리 열기",
		"ui.rule_book.title": "룰 북",
		"ui.rule_book.subtitle": "호텔 야간 규칙",
		"ui.rule_book.rule.1": "프론트 벨이 두 번 울리면 두 번째 벨에는 응답하지 마십시오.",
		"ui.rule_book.rule.2": "복도 문에서 호실 번호가 사라진 방에는 절대 들어가지 마십시오.",
		"ui.rule_book.rule.3": "세탁실 세탁기 문이 저절로 닫히면 세 번째 발소리 전에 나가십시오.",
		"ui.rule_book.rule.4": "손님이 108호를 찾으면 먼저 그 손님의 반사가 보이는지 확인하십시오.",
		"ui.rule_book.rule.5": "자정 이후 외부 계단에서 들리는 목소리를 따라가지 마십시오.",
		"ui.rule_book.rule.6": "화장실 불이 세 번 깜빡이면 멈출 때까지 문을 열어두십시오.",
		"ui.rule_book.rule.7": "이 호텔에는 지하가 없습니다. 지하 표지판을 보면 프론트로 돌아오십시오.",
		"item.room_105_key.name": "105호 열쇠",
		"item.room_105_key.description": "프론트 서랍에서 나온 낡은 황동 열쇠입니다.",
		"item.small_flashlight.name": "손전등",
		"item.small_flashlight.description": "작은 손전등입니다. 전기가 나가면 쓸모가 있습니다.",
		"item.guest_note.name": "손님 메모",
		"item.guest_note.description": "연필로 방 번호가 적힌 접힌 메모입니다.",
		"hotspot.laundry_room.laundry_second_washer.opened": "두 번째 세탁기 문이 열렸습니다.",
		"hotspot.laundry_room.laundry_second_washer.closed": "두 번째 세탁기 문이 닫혔습니다.",
	},
	Language.JAPANESE: {
		"ui.menu.title": "メニュー",
		"ui.menu.continue": "続ける",
		"ui.menu.inventory": "インベントリ",
		"ui.menu.rule_book": "ルールブック",
		"ui.menu.brightness": "明るさ",
		"ui.menu.quit": "終了",
		"ui.inventory.title": "インベントリ",
		"ui.inventory.hint": "アイテムをHandへドラッグすると装備できます。",
		"ui.inventory.empty": "アイテムはまだありません。",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "ここにアイテムを置く",
		"ui.equipment.empty": "なし",
		"ui.equipment.tooltip": "インベントリを開く",
		"ui.rule_book.title": "ルールブック",
		"ui.rule_book.subtitle": "ホテル夜間規則",
		"ui.rule_book.rule.1": "フロントのベルが二度鳴ったら、二度目には応じないこと。",
		"ui.rule_book.rule.2": "廊下のドアから部屋番号が消えている部屋には入らないこと。",
		"ui.rule_book.rule.3": "ランドリーの洗濯機がひとりでに閉まったら、三歩目の足音の前に出ること。",
		"ui.rule_book.rule.4": "客が108号室を求めたら、先にその客の反射があるか確認すること。",
		"ui.rule_book.rule.5": "深夜以降、外階段から聞こえる声について行かないこと。",
		"ui.rule_book.rule.6": "浴室の灯りが三度ちらついたら、止まるまで扉を開けておくこと。",
		"ui.rule_book.rule.7": "このホテルに地下はありません。地下の標識を見たらフロントへ戻ること。",
		"item.room_105_key.name": "105号室の鍵",
		"item.room_105_key.description": "フロントの引き出しにあった古い真鍮の鍵です。",
		"item.small_flashlight.name": "懐中電灯",
		"item.small_flashlight.description": "小型の懐中電灯です。停電時に役立ちます。",
		"item.guest_note.name": "客のメモ",
		"item.guest_note.description": "鉛筆で部屋番号が書かれた折りたたみメモです。",
	},
	Language.RUSSIAN: {
		"ui.menu.title": "Меню",
		"ui.menu.continue": "Продолжить",
		"ui.menu.inventory": "Инвентарь",
		"ui.menu.rule_book": "Книга правил",
		"ui.menu.brightness": "Яркость",
		"ui.menu.quit": "Выйти",
		"ui.inventory.title": "Инвентарь",
		"ui.inventory.hint": "Перетащите предмет в Hand, чтобы экипировать его.",
		"ui.inventory.empty": "Предметов пока нет.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "Перетащите предмет сюда",
		"ui.equipment.empty": "Пусто",
		"ui.equipment.tooltip": "Открыть инвентарь",
		"ui.rule_book.title": "Книга правил",
		"ui.rule_book.subtitle": "Ночные правила отеля",
		"ui.rule_book.rule.1": "Если звонок на стойке прозвенит дважды, не отвечайте на второй звонок.",
		"ui.rule_book.rule.2": "Никогда не входите в номер, если номер исчез с двери в коридоре.",
		"ui.rule_book.rule.3": "Если дверца стиральной машины закрылась сама, уйдите до третьего шага.",
		"ui.rule_book.rule.4": "Если гость просит номер 108, сначала проверьте, есть ли у него отражение.",
		"ui.rule_book.rule.5": "После полуночи не идите на голоса с наружной лестницы.",
		"ui.rule_book.rule.6": "Если свет в ванной мигнул три раза, держите дверь открытой, пока он не перестанет.",
		"ui.rule_book.rule.7": "В этом отеле нет подвала. Если увидите указатель в подвал, вернитесь к стойке.",
		"item.room_105_key.name": "Ключ от номера 105",
		"item.room_105_key.description": "Потертый латунный ключ из ящика стойки регистрации.",
		"item.small_flashlight.name": "Фонарик",
		"item.small_flashlight.description": "Компактный фонарик. Пригодится, если отключится электричество.",
		"item.guest_note.name": "Записка гостя",
		"item.guest_note.description": "Сложенная записка с номером комнаты, написанным карандашом.",
	},
	Language.CHINESE: {
		"ui.menu.title": "菜单",
		"ui.menu.continue": "继续",
		"ui.menu.inventory": "物品栏",
		"ui.menu.rule_book": "规则书",
		"ui.menu.brightness": "亮度",
		"ui.menu.quit": "退出",
		"ui.inventory.title": "物品栏",
		"ui.inventory.hint": "将物品拖到 Hand 即可装备。",
		"ui.inventory.empty": "还没有物品。",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "将物品放在这里",
		"ui.equipment.empty": "空",
		"ui.equipment.tooltip": "打开物品栏",
		"ui.rule_book.title": "规则书",
		"ui.rule_book.subtitle": "酒店夜间规则",
		"ui.rule_book.rule.1": "如果前台铃响两次，请不要回应第二次铃声。",
		"ui.rule_book.rule.2": "如果走廊房门上的房号消失，绝不要进入那个房间。",
		"ui.rule_book.rule.3": "如果洗衣房的洗衣机门自己关上，请在第三个脚步声前离开。",
		"ui.rule_book.rule.4": "如果客人询问108号房，请先确认他是否有倒影。",
		"ui.rule_book.rule.5": "午夜后不要跟随室外楼梯传来的声音。",
		"ui.rule_book.rule.6": "如果浴室灯闪烁三次，请保持门打开，直到它停止。",
		"ui.rule_book.rule.7": "本酒店没有地下室。如果看到地下室标志，请返回前台。",
		"item.room_105_key.name": "105号房钥匙",
		"item.room_105_key.description": "前台抽屉里的一把旧黄铜钥匙。",
		"item.small_flashlight.name": "手电筒",
		"item.small_flashlight.description": "一支小手电。停电时会派上用场。",
		"item.guest_note.name": "客人便条",
		"item.guest_note.description": "一张折起来的便条，上面用铅笔写着房号。",
	},
}


func set_language(language: int) -> void:
	if SUPPORTED_LANGUAGES.has(language):
		current_language = language


func get_language() -> int:
	return current_language


func get_language_code() -> String:
	return LANGUAGE_CODES.get(current_language, LANGUAGE_CODES[DEFAULT_LANGUAGE])


func get_supported_languages() -> Array:
	return SUPPORTED_LANGUAGES.duplicate()


func translate(key: String, fallback: String = "") -> String:
	var table: Dictionary = translations.get(current_language, {})
	if table.has(key):
		return table[key]

	var english_table: Dictionary = translations.get(DEFAULT_LANGUAGE, {})
	if english_table.has(key):
		return english_table[key]

	return fallback


func translate_ui(key: String, fallback: String = "") -> String:
	return translate("ui.%s" % key, fallback)


func translate_item_name(item_id: String, fallback: String = "") -> String:
	return translate("item.%s.name" % item_id, fallback)


func translate_item_description(item_id: String, fallback: String = "") -> String:
	return translate("item.%s.description" % item_id, fallback)


func translate_scene_photo(scene_id: String, fallback: String = "", variant := "") -> String:
	var key := "scene.%s.photo" % scene_id
	if not variant.is_empty():
		key = "%s.%s" % [key, variant]

	return translate(key, fallback)
