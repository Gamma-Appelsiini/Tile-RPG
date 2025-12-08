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
	#name_label.text = gchar.display_name
	picture_container.set_info(gchar)
	skill_panel.set_stat_handler(gchar.stat_handler)
	xp_panel.set_stat_handler(gchar.stat_handler)
	_update_values()

func _update_values() -> void:
	picture_container.update_values(stats)
	main_stat_panel.update_stats(stats)
	defence_panel.update_defs(stats)
	resistance_panel.update_resistances(stats)

func _on_button_pressed() -> void:
	pass # Replace with function body.
