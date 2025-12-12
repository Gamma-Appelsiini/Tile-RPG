extends Control
class_name StatWindow

var stats:StatHandler = null
@onready var picture_container: PictureContainer = %PictureContainer
@onready var main_stat_panel: MainStatPanel = %MainStatPanel
@onready var defence_panel: DefencePanel = $PanelContainer/VBoxContainer/DefencePanel
@onready var resistance_panel: ResistancePanel = $PanelContainer/VBoxContainer/ResistancePanel
@onready var x_button: XButton = $x_button
@export var skill_panel: SkillPanel = null
@export var xp_panel: XpPanel = null

func _ready() -> void:
	main_stat_panel.fill_main_stats()
	x_button.x_pressed.connect(func(): self.hide())

func set_game_character(gchar:GameCharacter) -> void:
	stats = gchar.stat_handler
	stats.stats_changed.connect(_update_values)
	
	picture_container.set_info(gchar)
	skill_panel.set_stat_handler(stats)
	xp_panel.set_stat_handler(stats)
	main_stat_panel.set_stat_hanlder(stats)
	_update_values()

func _update_values() -> void:
	picture_container.update_values(stats)
	defence_panel.update_defs(stats)
	resistance_panel.update_resistances(stats)
