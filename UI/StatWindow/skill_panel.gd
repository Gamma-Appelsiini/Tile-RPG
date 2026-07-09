extends Control
class_name SkillPanel

@export var grid_container: HBoxContainer = null

const STAT_AMOUNT_BOX := preload("uid://baa3wachk2q7f")

var stat_handler:StatHandler = null

func _ready() -> void:
	for skill:Stats.SkillStat in EnumStrings.SKILLS_NAMES.keys():
		var new_box:StatAmountBox = STAT_AMOUNT_BOX.instantiate()
		new_box.set_stat(skill)
		grid_container.add_child(new_box)

func set_stat_handler(new_sh:StatHandler) -> void:
	stat_handler = new_sh
	new_sh.stats_changed.connect(_update_skills)

func _update_skills() -> void:
	for stat_box:StatAmountBox in grid_container.get_children():
		stat_box.update_amount(stat_handler.get_stat_amount(stat_box.stat))
