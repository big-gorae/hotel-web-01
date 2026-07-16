class_name HotelCleanStainTaskBehavior
extends HotelTaskBehavior


func can_perform(definition, context) -> bool:
	return definition != null and context != null and not String(definition.required_item_id).is_empty() and String(context.equipped_item_id) == String(definition.required_item_id)
