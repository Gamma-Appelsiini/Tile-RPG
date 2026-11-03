extends MarginContainer
class_name SkillsPanel

@export var skills_container: HBoxContainer

const STAT_PANEL := preload("uid://cs0lekbgmxbn6")

func _ready() -> void:
	_set_stats()
	
func _set_stats() -> void:
	for skill:Stats.SkillStat in Stats.SkillStat.values():
		var new_stat_panel:StatPanel = STAT_PANEL.instantiate()
		new_stat_panel.set_stat(skill)
		skills_container.add_child(new_stat_panel)
