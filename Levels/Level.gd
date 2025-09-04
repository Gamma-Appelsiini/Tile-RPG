extends Node
class_name Level

@export var unique_id:String = ""
@export var game_characters_node:Node = null
@export var interactables_node:Node = null

@export var player_spawn_positions:Dictionary[String,Node3D] = {}

var game_chars:Array[GameCharacter] = []
#TODO add other types of loadable things in level

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)
	
	for gchar:GameCharacter in game_characters_node.get_children():
		game_chars.push_back(gchar as GameCharacter)

func save_to_data(save_data:Dictionary) -> void:
	#TODO add other things needed to be saved in levels
	save_data["levels"][unique_id] = {"interactables": {}}
	_save_gchars(save_data)
	_save_interactables(save_data["levels"][unique_id]["interactables"])

func _save_gchars(save_data:Dictionary) -> void:
	for gchar:GameCharacter in game_chars:
		gchar.save_to_data(save_data)
		
func _save_interactables(interactables_data:Dictionary) -> void:	
	for inter:Interactable in interactables_node.get_children():
		inter.save_to_data(interactables_data)

func _load_interactables(save_data:Dictionary) -> void:
	for inter:Interactable in interactables_node.get_children():
		inter.load_from_data(save_data)

func load_from_data(save_data:Dictionary) -> void:
	var levels:Dictionary = save_data["levels"]
	if !levels.has(unique_id):
		print(unique_id, " level not in save data")
		return
	
	_load_game_chars(save_data)
	_load_interactables(save_data["levels"][unique_id]["interactables"])

func _load_game_chars(save_data:Dictionary) -> void:
	#String array
	var dead_ids:Array = save_data["dead_ids"]
	
	for gchar:GameCharacter in game_chars:
		if dead_ids.has(gchar.unique_id):
			game_chars.erase(gchar)
			gchar.queue_free()
		else: gchar.load_from_data(save_data)
