extends MarginContainer
class_name SkillsPanel

@export var skills_container: HBoxContainer

const STAT_PANEL := preload("uid://cs0lekbgmxbn6")

var stat_panels:Array[StatPanel] = []

func _ready() -> void:
	_set_stats()
	
func _set_stats() -> void:
	for skill:Stats.SkillStat in Stats.SkillStat.values():
		var new_stat_panel:StatPanel = STAT_PANEL.instantiate()
		new_stat_panel.set_stat(skill)
		skills_container.add_child(new_stat_panel)
		stat_panels.push_back(new_stat_panel)

func update_stats(stat_handler:StatHandler) -> void:
	for stat_panel:StatPanel in stat_panels:
		stat_panel.update_amount(stat_handler)
