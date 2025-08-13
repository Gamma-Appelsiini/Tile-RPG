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

func load_from_data(save_data:Dictionary) -> void:
	var characters:Dictionary = save_data["game_characters"]
	if !characters.has(unique_id):
		print(unique_id, " not in save data")
		return
		
	var gpos:Vector3 = save_data["game_characters"][unique_id]["global_position"]
	if is_inside_tree():
		self.global_position = gpos

func save_to_data(save_data:Dictionary) -> void:
	if !save_data["game_characters"].has(unique_id):
		save_data["game_characters"][unique_id] = {}
	
	#TODO add other things characters need saving	
	save_data["game_characters"][unique_id]["global_position"] = self.global_position
	stat_handler.save_to_data(save_data,self.unique_id)
