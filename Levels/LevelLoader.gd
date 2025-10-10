extends Node
class_name LevelLoader

signal load_complete

const PLAYER_PATH:String = "res://Tile-RPG/GameCharacters/Player/player.tscn"
const SAVE_FILE_PATH:String = "res://Tile-RPG/SaveData/save_data.bin"
const LEVEL_FILES:LevelFiles = preload("res://Tile-RPG/Levels/level_files.tres")
@export var inventory: Inventory = null
@export var globe_ui:GlobeUI = null
@export var ui_handler: UIHandler = null

var save_file:JSON = null
var save_data:Dictionary = {
	"last_level_id": "test_level_1",
	"levels": {},
	"inventory": {},
	"game_characters": {},
	"dead_ids": [],
}

var player:Player = null
var current_level:Level = null

func _ready() -> void:
	await ui_handler.ready
	_load_bin_file()
	_load_player()
	_load_inv()
	
	var last_level_id:String = save_data["last_level_id"]
	var loading:bool = false
	if last_level_id != "test_level_1": loading = true
	change_levels(last_level_id,loading)
	
	GlobalSignals.connect("change_level",change_levels)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		save_save_file()

func _load_inv() -> void:
	await inventory.ready
	inventory.load_inv_from_data(save_data)

func _load_player() -> void:
	player = load(PLAYER_PATH).instantiate()
	player.load_from_data(save_data)
	
	ui_handler.set_player(player)
	_connect_globes()

func _connect_globes() -> void:
	globe_ui.set_viewport_path(player.hp_globe.get_viewport_path())
	player.stat_handler.stats_changed.connect(player.hp_globe.resource_changed.bind(player.stat_handler,ResourceGlobe.LiquidType.HP))
	
	globe_ui.set_viewport_path(player.spirit_globe.get_viewport_path(), globe_ui.spirit_viewport_texture_rect)
	player.stat_handler.stats_changed.connect(player.spirit_globe.resource_changed.bind(player.stat_handler,ResourceGlobe.LiquidType.SPIRIT))

func _load_bin_file() -> void:
	return
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file")
		return

	var file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data:Dictionary = file.get_var()
	save_data = data.duplicate()

	file.close()

func _save_current_level():
	save_data["last_level_id"] = current_level.unique_id
	current_level.save_to_data(save_data)

func save_save_file() -> void:
	save_player()
	_save_current_level()
	inventory.save_inv_to_data(save_data)
	
	#Creates new file if does not exist
	var file:FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data.duplicate())
	file.close()
	
func _close_current_level() -> void:
	if !current_level: return
	
	current_level.save_to_data(save_data)
	current_level.remove_child(player)
	self.remove_child(current_level)
	current_level.queue_free()

func _open_new_level(new_level_id:String, loading:bool = false) -> void:
	if new_level_id not in LEVEL_FILES.levels.keys():
		print("ERROR: Level ID not in LEVEL_FILES. ID: ", new_level_id)
		return
	
	var new_level_path:String = LEVEL_FILES.levels[new_level_id]
	current_level = load(new_level_path).instantiate()
	current_level.load_from_data(save_data)
	current_level.tile_manager.set_player(player)
	GlobalSignals.current_level = current_level
	
	for gc:GameCharacter in current_level.game_characters_node.get_children():
		if gc.follow_hander != null: gc.follow_hander.set_tile_manager(current_level.tile_manager)
	
	self.add_child(current_level)
	current_level.add_child(player)
	
	if !loading: player.global_position = current_level.player_spawn_positions[player.came_from_id].global_position
	else: player.global_position = save_data["game_characters"][player.unique_id]["global_position"]
	
	player.player_camera.make_current()

func change_levels(new_level_id:String, loading:bool = false) -> void:
	print("Change to level: ", new_level_id)
	
	_close_current_level()
	_open_new_level(new_level_id,loading)
	
	load_complete.emit()

func save_player() -> void:
	player.save_to_data(save_data)
	#TODO add player specific saving (inventory, quests)
