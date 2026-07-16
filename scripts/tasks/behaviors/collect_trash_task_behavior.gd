class_name HotelCollectTrashTaskBehavior
extends HotelTaskBehavior


func perform(definition, context) -> Dictionary:
	var result := super.perform(definition, context)
	if bool(result.get("success", false)):
		result["effect"] = "collect_trash"
	return result
