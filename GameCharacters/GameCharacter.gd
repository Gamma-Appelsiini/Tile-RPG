extends CharacterBody3D
class_name GameCharacter

@export var unique_id:String = ""
@export var stat_resource:StatResource = null
var stat_handler:StatHandler = null

func _init() -> void:
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)
	
func load_from_json(json:JSON) -> void:
	var data = json.data
	var characters:Dictionary = data["game_characters"]
	if !characters.has(unique_id):
		print(unique_id, " not in save data")
		return
	
	stat_handler.load_from_json(json,self.unique_id)
	self.global_position = characters[unique_id]["global_position"]

func check_char(json:JSON) -> void:
	var data = json.data
	var characters:Dictionary = data["game_characters"]
	if characters.has(unique_id): return
	
	var new_data:Dictionary = {"stat_handler": {}, "global_position": Vector3.ZERO}
	characters.set(unique_id, new_data)
	data["game_characters"] = characters
	json.data = data

func save_to_json(json:JSON) -> void:
	check_char(json)
	stat_handler.save_to_json(json,self.unique_id)
	#TODO add other things characters need saving
	
	var data = json.data
	var characters:Dictionary = data.get("game_characters", {})

	if not characters.has(unique_id):
		characters[unique_id] = {}

	characters[unique_id]["global_position"] = self.global_position
	data["game_characters"] = characters
	json.data = data
