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
	var data = json.data
	var characters:Dictionary = data["game_characters"]

	if characters.has(unique_id):
		stat_handler.load_from_json(characters[unique_id]["stat_handler"])

func save_to_json(json:JSON) -> void:
	var stat_data:String = stat_handler.save_to_json()
	#TODO add other things characters need saving
	
	var data = json.data
	var characters:Dictionary = data.get("game_characters", {})

	if not characters.has(unique_id):
		characters[unique_id] = {}

	var stat_data_dict = JSON.parse_string(stat_data)

	characters[unique_id]["stat_handler"] = stat_data_dict
	data["game_characters"] = characters
	json.data = data
