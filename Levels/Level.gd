extends Node
class_name Level

@export var unique_id:String = ""
@export var game_character_node:Node3D = null

@export var player_spawn_positions:Dictionary[String,Node3D] = {}
var game_chars:Array[GameCharacter] = []
#TODO add other types of loadable things in level

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)
	
	for gchar:GameCharacter in game_character_node.get_children():
		game_chars.push_back(gchar as GameCharacter)

func save_to_data(save_data:Dictionary) -> void:
	#TODO add other things needed to be saved in levels
	for gchar:GameCharacter in game_chars:
		gchar.save_to_data(save_data)
	

func load_from_data(save_data:Dictionary) -> void:
	var levels:Dictionary = save_data["levels"]
	if !levels.has(unique_id):
		print(unique_id, " level not in save data")
		return

func _load_game_chars(save_data:Dictionary) -> void:
	var dead_ids:Array[String] = save_data["dead_ids"]
	
	for gchar:GameCharacter in game_chars:
		if dead_ids.has(gchar.unique_id):
			game_chars.erase(gchar)
			gchar.queue_free()
		else: gchar.load_from_data(save_data)
