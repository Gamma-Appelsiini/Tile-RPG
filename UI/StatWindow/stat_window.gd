extends Control
class_name StatWindow

var stats:StatHandler = null
@onready var name_label: Label = %NameLabel
@onready var picture_container: PictureContainer = %PictureContainer
@onready var main_stat_panel: MainStatPanel = %MainStatPanel

func _ready() -> void:
	#var p:Player = load("res://Tile-RPG/GameCharacters/Player/player.tscn").instantiate()
	var sh:StatHandler = StatHandler.new()
	main_stat_panel.fill_main_stats(sh)

func set_game_character(gchar:GameCharacter) -> void:
	stats = gchar.stat_handler
	stats.stats_changed.connect(_update_values)
	name_label.text = gchar.display_name

func _update_values() -> void:
	pass
