extends Node
class_name LevelLoader

signal load_complete

const SAVE_FILE:JSON = preload("res://Tile-RPG/SaveData/save_data.tres")
const LEVEL_FILES:LevelFiles = preload("res://Tile-RPG/Levels/level_files.tres")

var player:Player = null
var current_level:Level = null

func _ready() -> void:
	player = load("res://Tile-RPG/GameCharacters/Player/player.tscn").instantiate()
	player.load_from_json(SAVE_FILE)

func change_levels(new_level_id:String):
	if current_level:
		current_level.save_to_json(SAVE_FILE)
		current_level.game_character_node.remove_child(player)
		self.remove_child(current_level)
		current_level.queue_free()
	
	var new_level_path:String = LEVEL_FILES.levels[new_level_id]
	current_level = load(new_level_path).instantiate()
	current_level.load_from_json(SAVE_FILE)
	self.add_child(current_level)
	current_level.add_child(player)
	player.global_position = current_level.player_spawn_positions[player.came_from_id].global_position
	
	load_complete.emit()
