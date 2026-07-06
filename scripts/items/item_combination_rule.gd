class_name HotelItemCombinationRule
extends RefCounted

var id := ""
var item_a_id := ""
var item_b_id := ""
var result_item_ids: Array[String] = []
var consume_item_a := true
var consume_item_b := true
var ordered := false
var message_key := ""
var fallback_message := ""


func matches(source_item, target_item) -> bool:
	if source_item == null or target_item == null or source_item == target_item:
		return false

	if ordered:
		return source_item.id == item_a_id and target_item.id == item_b_id

	return (
		(source_item.id == item_a_id and target_item.id == item_b_id)
		or (source_item.id == item_b_id and target_item.id == item_a_id)
	)


func should_consume(item) -> bool:
	if item == null:
		return false

	if item.id == item_a_id:
		return consume_item_a

	if item.id == item_b_id:
		return consume_item_b

	return false
