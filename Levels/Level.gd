extends Node
class_name Level

@export var unique_id:String = ""
@export var game_character_node:Node3D = null

@export var player_spawn_positions:Dictionary[String,Node3D] = {}
var game_chars:Array[GameCharacter] = []
var dead_ids:Array[String] = []
#TODO add other types of loadable things in level

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)
	for gchar:GameCharacter in game_character_node.get_children():
		game_chars.push_back(gchar as GameCharacter)

func save_to_json(json:JSON):
	for gchar:GameCharacter in game_chars:
		gchar.save_to_json(json)
	
	
func load_from_json(json:JSON):
	if json == null or json.data == null:
		push_error("Invalid JSON input for Level load.")
		return

	var data = json.data
	var levels = data["Levels"]

	if levels.has(unique_id):
		print("Level '%s' found in save data." % unique_id)
	else:
		print("Level '%s' NOT found in save data." % unique_id)
