extends CharacterBody3D
class_name GameCharacter

@export var unique_id:String = ""
@export var stat_resource:StatResource = null
var stat_handler:StatHandler = null

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)

func load_from_json(json:JSON) -> void:
	#Check if json contains this gamecharacter
	stat_handler.load_from_json(json.data)

func save_to_json(json:JSON) -> void:
	var string_data:String = stat_handler.save_to_json()
