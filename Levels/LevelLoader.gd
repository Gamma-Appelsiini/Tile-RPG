extends Node
class_name LevelLoader

signal load_complete
signal resource_loader_finished_loading

const PLAYER_PATH:String = "res://Tile-RPG/GameCharacters/Player/player.tscn"
const SAVE_FILE_PATH:String = "res://Tile-RPG/SaveData/"
const SAVE_SUFFIX:String = "/save_data.bin"
const SCREENSHOT_SUFFIX:String = "/screenshot.png"
const LEVEL_FILES:LevelFiles = preload("res://Tile-RPG/Levels/level_files.tres")

@export var inventory: Inventory = null
@export var globe_ui:GlobeUI = null
@export var ui_handler: UIHandler = null
@export var ability_targeter:AbilityTargeter = null
@export var loading_screen: LoadingScreen = null

var save_file_folder_path:String = "res://Tile-RPG/SaveData/slot1/"
var save_file:JSON = null
var save_data:Dictionary = {
	"last_level_id": "jail_01",
	"levels": {},
	"inventory": {},
	"ability_bar": [],
	"abilities_container": [],
	"game_characters": {},
	"dead_ids": [],
	"quest_handler": {},
	"shops": [],
}

var player:Player = null
var current_level:Level = null

func _ready() -> void:
	set_process(false)
	GlobalSignals.connect("change_level", change_levels)
	GlobalSignals.load_game.connect(load_game)
	GlobalSignals.save_game.connect(save_game)

func new_game() -> void:
	#TODO new game deletes old save
	
	save_data = {
	"last_level_id": "jail_01",
	"levels": {},
	"inventory": {},
	"ability_bar": [],
	"abilities_container": [],
	"game_characters": {},
	"dead_ids": [],
	"quest_handler": {},
	"shops": [],
	"save_date": "",
	}
	
	load_game(false)

func load_game_from_path(path:String) -> void:
	if !FileAccess.file_exists(path):
		print_debug("No save file with path: ", path)
		return

	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = file.get_var()
	save_data = data.duplicate()
	file.close()
	
	#TODO inventory is empty
	load_game()

func load_game(loading:bool = true) -> void:
	var last_level_id:String = save_data["last_level_id"]
	_load_quest_handler()
	
	loading_screen.load_next_level(last_level_id, true)
	await loading_screen.loading_complete
	
	_load_player(loading_screen.loaded_player)
	_close_current_level()
	
	var new_level:Level = loading_screen.loaded_level
	_open_new_level(new_level,loading)

	load_complete.emit()

func change_levels(new_level_id:String) -> void:
	loading_screen.load_next_level(new_level_id, false)
	await loading_screen.loading_complete
	
	_close_current_level()
	
	var new_level:Level = loading_screen.loaded_level
	_open_new_level(new_level, false)
	load_complete.emit()

func _load_quest_handler() -> void:
	var new_q_handler:QuestHandler = QuestHandler.new()
	GlobalSignals.quest_handler = new_q_handler
	new_q_handler.load_from_data(save_data)

func _load_player(new_player:Player) -> void:
	if player: player.queue_free()
	
	player = new_player
	player.load_from_data(save_data)
	
	ui_handler.set_player(player)
	ui_handler.load_from_data(save_data)
	_connect_globes()

func _connect_globes() -> void:
	globe_ui.set_viewport_path(player.hp_globe.get_viewport_path())
	player.stat_handler.stats_changed.connect(player.hp_globe.resource_changed.bind(player.stat_handler,ResourceGlobe.LiquidType.HP))
	
	globe_ui.set_viewport_path(player.spirit_globe.get_viewport_path(), globe_ui.spirit_panel)
	player.stat_handler.stats_changed.connect(player.spirit_globe.resource_changed.bind(player.stat_handler,ResourceGlobe.LiquidType.SPIRIT))

func _save_current_level():
	save_data["last_level_id"] = current_level.unique_id
	current_level.save_to_data(save_data)

func save_game() -> void:
	save_player()
	_save_current_level()
	ui_handler.save_to_data(save_data)
	save_data["save_date"] = Time.get_datetime_string_from_system().replace(":", "-")
	
	#Creates new file if does not exist
	var file:FileAccess = FileAccess.open(save_file_folder_path + SAVE_SUFFIX, FileAccess.WRITE)
	file.store_var(save_data.duplicate())
	file.close()

func _take_screenshot() -> void:
	await RenderingServer.frame_post_draw
	
	var viewport:Viewport = get_viewport()
	var texture:ViewportTexture = viewport.get_texture()
	var image:Image = texture.get_image()
	
	image.resize(854, 480, Image.INTERPOLATE_LANCZOS)
	var image_save_path:String = save_file_folder_path + SCREENSHOT_SUFFIX
	
	var error := image.save_png(image_save_path)
	if error != OK: print_debug("Failed to save screenshot. Error code: ", error)

func _close_current_level() -> void:
	if !current_level: return
	
	current_level.save_to_data(save_data)
	if player.get_parent(): current_level.remove_child(player)
	self.remove_child(current_level)
	current_level.queue_free()

func _open_new_level(new_level:Level, loading:bool = false) -> void:
	current_level = new_level
	current_level.load_from_data(save_data)
	current_level.tile_manager.set_player(player)
	GlobalSignals.current_level = current_level
	ability_targeter.tile_manager = current_level.tile_manager
	
	for gc:GameCharacter in current_level.game_characters_node.get_children():
		if gc.follow_hander != null: gc.follow_hander.set_tile_manager(current_level.tile_manager)
	
	self.add_child(current_level)
	current_level.add_child(player)
	
	if !loading: player.global_position = current_level.player_spawn_positions[player.came_from_id].global_position
	else: player.global_position = save_data["game_characters"][player.unique_id]["global_position"]
	
	player.player_camera.make_current()

func save_player() -> void:
	player.save_to_data(save_data)
	
	#TODO add player specific saving (inventory, quests)
