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
		"ui.menu.main_menu": "Main Menu",
		"ui.menu.quit": "Quit",
		"ui.day.label": "Day %d",
		"ui.lobby.title": "Night Shift",
		"ui.lobby.subtitle": "The front desk is waiting.",
		"ui.lobby.start_shift": "Start Shift",
		"ui.lobby.continue": "Continue",
		"ui.lobby.continue.available": "Choose a saved day to continue.",
		"ui.lobby.continue.disabled": "No saved days yet.",
		"ui.lobby.choose_day": "Choose Day",
		"ui.lobby.save_status": "Latest saved day: %s",
		"ui.lobby.no_save_status": "No saved shift yet.",
		"ui.lobby.day.saved": "Start from this saved day.",
		"ui.lobby.day.locked": "Reach this day first.",
		"ui.lobby.horror_summary": "%s",
		"ui.lobby.quit": "Quit",
		"ui.inventory.title": "Inventory",
		"ui.inventory.hint": "Drag an item to Hand to equip it. Drop an item onto another item to combine them.",
		"ui.inventory.empty": "No items yet.",
		"ui.inventory.combine.no_match": "Those items do not fit together.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "Drag item here",
		"ui.equipment.empty": "Empty",
		"ui.equipment.tooltip": "Open inventory",
		"ui.rule_book.title": "Rule Book",
		"ui.rule_book.subtitle": "Hotel night rules",
		"ui.rule_book.rule.1": "Keep the front desk phone within reach during the night shift.",
		"ui.rule_book.rule.2": "Check the room log before giving out or accepting any key.",
		"ui.rule_book.rule.3": "Guests may use the laundry room, but the second washer should be left closed after 11 PM.",
		"ui.rule_book.rule.4": "If a room door is open when your log says it is vacant, knock once and wait before entering.",
		"ui.rule_book.rule.5": "If the corridor lights flicker, return to the front desk and compare the room numbers with the log.",
		"ui.rule_book.rule.6": "If a guest asks for a room that is already occupied, ask them to write their name before you look up.",
		"ui.rule_book.rule.7": "If your handwritten log contains a rule you do not remember writing, obey it until sunrise.",
		"ui.debug.hotspots.show": "Show click areas",
		"ui.debug.hotspots.hide": "Hide click areas",
		"ui.debug.dialogue.show": "Show dialogue panel",
		"ui.debug.dialogue.hide": "Hide dialogue panel",
		"ui.debug.navigation.show": "Show quick travel buttons",
		"ui.debug.navigation.hide": "Hide quick travel buttons",
		"ui.debug.days.title": "Day",
		"ui.debug.days.tooltip": "Jump to this day and autosave the current day.",
		"item.room_105_key.name": "Room 105 Key",
		"item.room_105_key.description": "A worn brass key from the front desk drawer.",
		"item.small_flashlight.name": "Flashlight",
		"item.small_flashlight.description": "A compact flashlight. Useful when the power fails.",
		"item.guest_note.name": "Guest Note",
		"item.guest_note.description": "A folded note with a room number written in pencil.",
		"item.revealed_guest_note.name": "Revealed Note",
		"item.revealed_guest_note.description": "The flashlight reveals faint writing under the room number: Do not return it after midnight.",
		"combine.reveal_guest_note": "The flashlight reveals hidden writing on the note.",
		"hotspot.laundry_room.laundry_second_washer.opened": "The second washer door is open.",
		"hotspot.laundry_room.laundry_second_washer.closed": "The second washer door is closed.",
	},
	Language.KOREAN: {
		"ui.menu.title": "메뉴",
		"ui.menu.continue": "계속하기",
		"ui.menu.inventory": "인벤토리",
		"ui.menu.rule_book": "룰 북",
		"ui.menu.brightness": "밝기",
		"ui.menu.main_menu": "메인 메뉴",
		"ui.menu.quit": "종료",
		"ui.day.label": "Day %d",
		"ui.lobby.title": "야간 근무",
		"ui.lobby.subtitle": "프론트 데스크가 기다리고 있습니다.",
		"ui.lobby.start_shift": "근무 시작",
		"ui.lobby.continue": "계속하기",
		"ui.lobby.continue.available": "저장된 day를 골라 이어서 시작합니다.",
		"ui.lobby.continue.disabled": "아직 저장된 day가 없습니다.",
		"ui.lobby.choose_day": "Day 선택",
		"ui.lobby.save_status": "최근 저장: %s",
		"ui.lobby.no_save_status": "저장된 근무가 없습니다.",
		"ui.lobby.day.saved": "이 저장 day에서 시작합니다.",
		"ui.lobby.day.locked": "먼저 이 day에 도달해야 합니다.",
		"ui.lobby.horror_summary": "%s",
		"ui.lobby.quit": "종료",
		"ui.inventory.title": "인벤토리",
		"ui.inventory.hint": "아이템을 Hand로 드래그하면 장착됩니다. 아이템 위에 다른 아이템을 놓으면 조합할 수 있습니다.",
		"ui.inventory.empty": "아직 아이템이 없습니다.",
		"ui.inventory.combine.no_match": "이 아이템들은 서로 맞지 않습니다.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "아이템을 여기에 놓기",
		"ui.equipment.empty": "비어 있음",
		"ui.equipment.tooltip": "인벤토리 열기",
		"ui.rule_book.title": "룰 북",
		"ui.rule_book.subtitle": "호텔 야간 규칙",
		"ui.rule_book.rule.1": "야간 근무 중에는 프론트 전화기를 손이 닿는 곳에 두십시오.",
		"ui.rule_book.rule.2": "열쇠를 내주거나 받을 때는 먼저 객실 기록부를 확인하십시오.",
		"ui.rule_book.rule.3": "손님은 세탁실을 사용할 수 있으나, 밤 11시 이후에는 두 번째 세탁기 문을 닫아두십시오.",
		"ui.rule_book.rule.4": "기록상 빈 방인데 문이 열려 있다면, 들어가기 전에 한 번 노크하고 기다리십시오.",
		"ui.rule_book.rule.5": "복도 조명이 깜빡이면 프론트로 돌아와 객실 번호와 기록부를 대조하십시오.",
		"ui.rule_book.rule.6": "이미 투숙 중인 방을 찾는 손님이 오면, 고개를 들기 전에 이름을 적게 하십시오.",
		"ui.rule_book.rule.7": "직접 쓴 기록부에 쓴 기억이 없는 규칙이 있다면, 해가 뜰 때까지 그 규칙을 따르십시오.",
		"ui.debug.days.title": "Day",
		"ui.debug.days.tooltip": "현재 day를 자동 저장하고 이 day로 이동합니다.",
		"item.room_105_key.name": "105호 열쇠",
		"item.room_105_key.description": "프론트 서랍에서 나온 낡은 황동 열쇠입니다.",
		"item.small_flashlight.name": "손전등",
		"item.small_flashlight.description": "작은 손전등입니다. 전기가 나가면 쓸모가 있습니다.",
		"item.guest_note.name": "손님 메모",
		"item.guest_note.description": "연필로 방 번호가 적힌 접힌 메모입니다.",
		"item.revealed_guest_note.name": "드러난 메모",
		"item.revealed_guest_note.description": "손전등을 비추자 방 번호 아래 희미한 문장이 보입니다. 자정 이후에는 돌려주지 말 것.",
		"combine.reveal_guest_note": "손전등 불빛 아래 메모의 숨은 글씨가 드러났습니다.",
		"hotspot.laundry_room.laundry_second_washer.opened": "두 번째 세탁기 문이 열렸습니다.",
		"hotspot.laundry_room.laundry_second_washer.closed": "두 번째 세탁기 문이 닫혔습니다.",
	},
	Language.JAPANESE: {
		"ui.menu.title": "メニュー",
		"ui.menu.continue": "続ける",
		"ui.menu.inventory": "インベントリ",
		"ui.menu.rule_book": "ルールブック",
		"ui.menu.brightness": "明るさ",
		"ui.menu.main_menu": "メインメニュー",
		"ui.menu.quit": "終了",
		"ui.day.label": "Day %d",
		"ui.lobby.title": "夜勤",
		"ui.lobby.subtitle": "フロントデスクが待っています。",
		"ui.lobby.start_shift": "勤務開始",
		"ui.lobby.continue": "続ける",
		"ui.lobby.continue.available": "保存済みの日を選んで再開します。",
		"ui.lobby.continue.disabled": "保存済みの日はまだありません。",
		"ui.lobby.choose_day": "Day 選択",
		"ui.lobby.save_status": "最新の保存: %s",
		"ui.lobby.no_save_status": "保存された勤務はありません。",
		"ui.lobby.day.saved": "この保存日から始めます。",
		"ui.lobby.day.locked": "先にこの日に到達してください。",
		"ui.lobby.horror_summary": "%s",
		"ui.lobby.quit": "終了",
		"ui.inventory.title": "インベントリ",
		"ui.inventory.hint": "アイテムをHandへドラッグすると装備できます。アイテム同士を重ねると組み合わせられます。",
		"ui.inventory.empty": "アイテムはまだありません。",
		"ui.inventory.combine.no_match": "そのアイテム同士は合いません。",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "ここにアイテムを置く",
		"ui.equipment.empty": "なし",
		"ui.equipment.tooltip": "インベントリを開く",
		"ui.rule_book.title": "ルールブック",
		"ui.rule_book.subtitle": "ホテル夜間規則",
		"ui.rule_book.rule.1": "夜勤中はフロントの電話を手の届く場所に置いてください。",
		"ui.rule_book.rule.2": "鍵を渡す、または受け取る前に、必ず客室記録を確認してください。",
		"ui.rule_book.rule.3": "ランドリーは利用可能ですが、午後11時以降は二台目の洗濯機の扉を閉めておいてください。",
		"ui.rule_book.rule.4": "記録上は空室なのに扉が開いている場合、入る前に一度だけノックして待ってください。",
		"ui.rule_book.rule.5": "廊下の灯りがちらついたら、フロントへ戻り、部屋番号を記録と照合してください。",
		"ui.rule_book.rule.6": "すでに使用中の部屋を求める客が来たら、顔を上げる前に名前を書かせてください。",
		"ui.rule_book.rule.7": "自分の筆跡の記録に、書いた覚えのない規則があれば、日の出までそれに従ってください。",
		"ui.debug.days.title": "Day",
		"ui.debug.days.tooltip": "現在の日を自動保存して、この日に移動します。",
		"item.room_105_key.name": "105号室の鍵",
		"item.room_105_key.description": "フロントの引き出しにあった古い真鍮の鍵です。",
		"item.small_flashlight.name": "懐中電灯",
		"item.small_flashlight.description": "小型の懐中電灯です。停電時に役立ちます。",
		"item.guest_note.name": "客のメモ",
		"item.guest_note.description": "鉛筆で部屋番号が書かれた折りたたみメモです。",
		"item.revealed_guest_note.name": "浮かび上がったメモ",
		"item.revealed_guest_note.description": "懐中電灯を当てると、部屋番号の下に薄い文字が見えます。深夜以降は返してはいけない。",
		"combine.reveal_guest_note": "懐中電灯の光でメモの隠れた文字が浮かび上がりました。",
	},
	Language.RUSSIAN: {
		"ui.menu.title": "Меню",
		"ui.menu.continue": "Продолжить",
		"ui.menu.inventory": "Инвентарь",
		"ui.menu.rule_book": "Книга правил",
		"ui.menu.brightness": "Яркость",
		"ui.menu.main_menu": "Главное меню",
		"ui.menu.quit": "Выйти",
		"ui.day.label": "Day %d",
		"ui.lobby.title": "Ночная смена",
		"ui.lobby.subtitle": "Стойка регистрации ждет.",
		"ui.lobby.start_shift": "Начать смену",
		"ui.lobby.continue": "Продолжить",
		"ui.lobby.continue.available": "Выберите сохраненный день для продолжения.",
		"ui.lobby.continue.disabled": "Сохраненных дней пока нет.",
		"ui.lobby.choose_day": "Выбрать Day",
		"ui.lobby.save_status": "Последнее сохранение: %s",
		"ui.lobby.no_save_status": "Сохраненной смены пока нет.",
		"ui.lobby.day.saved": "Начать с этого сохраненного дня.",
		"ui.lobby.day.locked": "Сначала дойдите до этого дня.",
		"ui.lobby.horror_summary": "%s",
		"ui.lobby.quit": "Выйти",
		"ui.inventory.title": "Инвентарь",
		"ui.inventory.hint": "Перетащите предмет в Hand, чтобы экипировать его. Перетащите предмет на другой предмет, чтобы объединить их.",
		"ui.inventory.empty": "Предметов пока нет.",
		"ui.inventory.combine.no_match": "Эти предметы не подходят друг к другу.",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "Перетащите предмет сюда",
		"ui.equipment.empty": "Пусто",
		"ui.equipment.tooltip": "Открыть инвентарь",
		"ui.rule_book.title": "Книга правил",
		"ui.rule_book.subtitle": "Ночные правила отеля",
		"ui.rule_book.rule.1": "Во время ночной смены держите телефон стойки регистрации под рукой.",
		"ui.rule_book.rule.2": "Перед выдачей или приемом ключа сверяйтесь с журналом номеров.",
		"ui.rule_book.rule.3": "Гости могут пользоваться прачечной, но после 23:00 дверца второй машины должна быть закрыта.",
		"ui.rule_book.rule.4": "Если номер числится пустым, но дверь открыта, постучите один раз и подождите перед входом.",
		"ui.rule_book.rule.5": "Если свет в коридоре мигает, вернитесь к стойке и сверните номера комнат с журналом.",
		"ui.rule_book.rule.6": "Если гость просит уже занятый номер, попросите его написать имя, прежде чем поднять взгляд.",
		"ui.rule_book.rule.7": "Если в вашем рукописном журнале есть правило, которое вы не помните, соблюдайте его до рассвета.",
		"ui.debug.days.title": "Day",
		"ui.debug.days.tooltip": "Автосохранить текущий день и перейти к этому дню.",
		"item.room_105_key.name": "Ключ от номера 105",
		"item.room_105_key.description": "Потертый латунный ключ из ящика стойки регистрации.",
		"item.small_flashlight.name": "Фонарик",
		"item.small_flashlight.description": "Компактный фонарик. Пригодится, если отключится электричество.",
		"item.guest_note.name": "Записка гостя",
		"item.guest_note.description": "Сложенная записка с номером комнаты, написанным карандашом.",
		"item.revealed_guest_note.name": "Проявленная записка",
		"item.revealed_guest_note.description": "В свете фонарика под номером комнаты видна бледная надпись: не возвращать после полуночи.",
		"combine.reveal_guest_note": "Свет фонарика проявляет скрытую надпись на записке.",
	},
	Language.CHINESE: {
		"ui.menu.title": "菜单",
		"ui.menu.continue": "继续",
		"ui.menu.inventory": "物品栏",
		"ui.menu.rule_book": "规则书",
		"ui.menu.brightness": "亮度",
		"ui.menu.main_menu": "主菜单",
		"ui.menu.quit": "退出",
		"ui.day.label": "Day %d",
		"ui.lobby.title": "夜班",
		"ui.lobby.subtitle": "前台正在等待。",
		"ui.lobby.start_shift": "开始值班",
		"ui.lobby.continue": "继续",
		"ui.lobby.continue.available": "选择已保存的日期继续。",
		"ui.lobby.continue.disabled": "还没有已保存的日期。",
		"ui.lobby.choose_day": "选择 Day",
		"ui.lobby.save_status": "最近保存：%s",
		"ui.lobby.no_save_status": "还没有保存的值班。",
		"ui.lobby.day.saved": "从这个已保存日期开始。",
		"ui.lobby.day.locked": "请先到达这个日期。",
		"ui.lobby.horror_summary": "%s",
		"ui.lobby.quit": "退出",
		"ui.inventory.title": "物品栏",
		"ui.inventory.hint": "将物品拖到 Hand 即可装备。把一个物品拖到另一个物品上即可尝试组合。",
		"ui.inventory.empty": "还没有物品。",
		"ui.inventory.combine.no_match": "这些物品无法组合。",
		"ui.inventory.hand.title": "Hand",
		"ui.inventory.hand.empty": "将物品放在这里",
		"ui.equipment.empty": "空",
		"ui.equipment.tooltip": "打开物品栏",
		"ui.rule_book.title": "规则书",
		"ui.rule_book.subtitle": "酒店夜间规则",
		"ui.rule_book.rule.1": "夜班期间，请将前台电话放在伸手可及的位置。",
		"ui.rule_book.rule.2": "交出或收回钥匙前，请先核对客房登记簿。",
		"ui.rule_book.rule.3": "客人可以使用洗衣房，但晚上11点后第二台洗衣机的门必须保持关闭。",
		"ui.rule_book.rule.4": "如果登记簿显示房间为空，但房门开着，进入前请先敲一次门并等待。",
		"ui.rule_book.rule.5": "如果走廊灯闪烁，请回到前台并把房号与登记簿核对。",
		"ui.rule_book.rule.6": "如果客人询问已入住的房间，请先让他写下名字，再抬头查看。",
		"ui.rule_book.rule.7": "如果你的手写登记簿中出现你不记得写过的规则，请遵守它直到日出。",
		"ui.debug.days.title": "Day",
		"ui.debug.days.tooltip": "自动保存当前日期并跳转到此日期。",
		"item.room_105_key.name": "105号房钥匙",
		"item.room_105_key.description": "前台抽屉里的一把旧黄铜钥匙。",
		"item.small_flashlight.name": "手电筒",
		"item.small_flashlight.description": "一支小手电。停电时会派上用场。",
		"item.guest_note.name": "客人便条",
		"item.guest_note.description": "一张折起来的便条，上面用铅笔写着房号。",
		"item.revealed_guest_note.name": "显现的便条",
		"item.revealed_guest_note.description": "手电光照出房号下方的淡字：午夜后不要归还。",
		"combine.reveal_guest_note": "手电光让便条上的隐藏文字显现出来。",
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
