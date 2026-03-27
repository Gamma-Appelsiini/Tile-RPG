extends Control
class_name LoadingScreen

signal player_loaded
signal level_loaded
signal loading_complete

@export var progress_bar: ProgressBar = null

const PLAYER_PATH:String = "res://Tile-RPG/GameCharacters/Player/player.tscn"
const LEVEL_FILES:LevelFiles = preload("res://Tile-RPG/Levels/level_files.tres")

var next_level_path:String = ""
var current_load_path:String = ""
var loaded_player:Player = null
var loaded_level:Level = null
var bar_tween:Tween = null

func _process(_delta: float) -> void:
	var loaded_status = ResourceLoader.load_threaded_get_status(current_load_path)
	
	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if current_load_path == PLAYER_PATH:
			loaded_player = ResourceLoader.load_threaded_get(current_load_path).instantiate()
			player_loaded.emit()
		elif current_load_path == next_level_path:
			loaded_level = ResourceLoader.load_threaded_get(current_load_path).instantiate()
			level_loaded.emit()

func _load_player() -> void:
	current_load_path = PLAYER_PATH
	ResourceLoader.load_threaded_request(PLAYER_PATH)
	await player_loaded

func _load_level(level_id:String) -> void:
	if level_id not in LEVEL_FILES.levels.keys():
		print("ERROR: Level ID not in LEVEL_FILES. ID: ", level_id)
		return
		
	next_level_path = LEVEL_FILES.levels[level_id]
	current_load_path = next_level_path
	ResourceLoader.load_threaded_request(next_level_path)
	await level_loaded

func load_next_level(level_id:String, load_player:bool) -> void:
	loaded_level = null
	loaded_player = null
	
	_show_loading()
	set_process(true)
	
	if load_player: await _load_player()
	await _load_level(level_id)
	
	set_process(false)
	current_load_path = ""
	_hide_loading()
	loading_complete.emit()

func _hide_loading() -> void:
	if bar_tween:
		bar_tween.kill()
		bar_tween = create_tween()
		bar_tween.tween_property(progress_bar,"value", 100, 0.2).set_ease(Tween.EASE_IN)
		await bar_tween.finished
		bar_tween = null

	var tween3:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween3.tween_property(self,"modulate:a", 0, 0.5)
	await tween3.finished

	hide()

func _show_loading() -> void:
	modulate.a = 0
	show()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self,"modulate:a", 1, 0.25)
	await tween.finished
	
	var tween2:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween2.tween_property(progress_bar,"value", 90, 4)
	bar_tween = tween2
