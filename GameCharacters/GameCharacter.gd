extends CharacterBody3D
class_name GameCharacter

@export var stat_resource:StatResource = null
var stat_handler:StatHandler = null

func _ready() -> void:
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)
