extends Control
class_name StatWindow

var stats:StatHandler = null
@onready var name_label: Label = %NameLabel
@onready var picture_container: PictureContainer = %PictureContainer
@onready var main_stat_panel: MainStatPanel = %MainStatPanel
@onready var defence_panel: DefencePanel = $PanelContainer/VBoxContainer/DefencePanel
@onready var xp_bar: TextureProgressBar = %XpBar
@onready var xp_label: Label = %XpLabel
@onready var xp_bar_panel: PanelContainer = %XpBarPanel
@onready var resistance_panel: ResistancePanel = $PanelContainer/VBoxContainer/ResistancePanel

func _ready() -> void:
	#var p:Player = load("res://Tile-RPG/GameCharacters/Player/player.tscn").instantiate()
	var sh:StatHandler = StatHandler.new()
	main_stat_panel.fill_main_stats()
	defence_panel.update_defs(sh)

func set_game_character(gchar:GameCharacter) -> void:
	stats = gchar.stat_handler
	stats.stats_changed.connect(_update_values)
	name_label.text = gchar.display_name

func _update_values() -> void:
	main_stat_panel.update_stats(stats)
	defence_panel.update_defs(stats)
	resistance_panel.update_resistances(stats)

func _update_xp_bar() -> void:
	var cur_xp:int = stats.char_stats[Stats.CharStat.CURRENT_XP]
	var max_xp:int = stats.char_stats[Stats.CharStat.MAX_XP]
	
	xp_label.text = str(cur_xp) + " / " + str(max_xp)
	xp_bar.max_value = max_xp
