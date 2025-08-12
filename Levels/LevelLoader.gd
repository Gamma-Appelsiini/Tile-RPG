extends Node
class_name LevelLoader

signal load_complete

const PLAYER_PATH:String = "res://Tile-RPG/GameCharacters/Player/player.tscn"
const SAVE_FILE_PATH:String = "res://Tile-RPG/SaveData/save_text.txt"
const LEVEL_FILES:LevelFiles = preload("res://Tile-RPG/Levels/level_files.tres")

var save_file:JSON = null
var player:Player = null
var current_level:Level = null

func _ready() -> void:
	_load_json_file()
	_load_player()
	var last_level_id:String = save_file.data["last_level_id"]
	change_levels(last_level_id)
	
	GlobalSignals.connect("change_level",change_levels)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		save_json_file()

func _load_player() -> void:
	player = load(PLAYER_PATH).instantiate()
	player.load_from_json(save_file)

func _load_json_file() -> void:
	var file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json:String = file.get_as_text()
	save_file = JSON.new()
	
	save_file.parse(json)
	print(save_file.data)
	file.close()

func _save_current_level():
	var data = save_file.data
	data["last_level_id"] = current_level.unique_id
	save_file.data = data
	current_level.save_to_json(save_file)

func save_json_file() -> void:
	save_player()
	_save_current_level()
	print(save_file.data)
	
	var file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var json_text:String = JSON.stringify(save_file.data, "\t")
	
	file.store_string(json_text)
	
func change_levels(new_level_id:String) -> void:
	print("Change to level: ", new_level_id)
	if current_level:
		current_level.save_to_json(save_file)
		current_level.remove_child(player)
		self.remove_child(current_level)
		current_level.queue_free()
	
	var new_level_path:String = LEVEL_FILES.levels[new_level_id]
	current_level = load(new_level_path).instantiate()
	current_level.load_from_json(save_file)
	
	self.add_child(current_level)
	current_level.add_child(player)
	player.global_position = current_level.player_spawn_positions[player.came_from_id].global_position
	player.player_camera.make_current()
	
	load_complete.emit()

func save_player() -> void:
	player.save_to_json(save_file)
	#TODO add player specific saving (inventory, quests)
