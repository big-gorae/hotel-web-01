class_name HotelTaskBehaviorRegistry
extends RefCounted

const DefaultBehavior := preload("res://scripts/tasks/behaviors/task_behavior.gd")
const FoldBeddingBehavior := preload("res://scripts/tasks/behaviors/fold_bedding_task_behavior.gd")
const CleanStainBehavior := preload("res://scripts/tasks/behaviors/clean_stain_task_behavior.gd")
const CollectTrashBehavior := preload("res://scripts/tasks/behaviors/collect_trash_task_behavior.gd")

var default_behavior = DefaultBehavior.new()
var behaviors: Dictionary = {
	"fold_bedding": FoldBeddingBehavior.new(),
	"clean_stain": CleanStainBehavior.new(),
	"collect_trash": CollectTrashBehavior.new(),
}


func get_behavior(task_type: String):
	return behaviors.get(task_type, default_behavior)
