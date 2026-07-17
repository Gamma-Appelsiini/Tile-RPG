extends PanelContainer
class_name CompactStatsPanel

@onready var main_stat_container: GridContainer = $HBoxContainer/MainStatContainer
@onready var def_container: GridContainer = $HBoxContainer/VBoxContainer/DefContainer
@onready var skill_container: HBoxContainer = $HBoxContainer/VBoxContainer/SkillContainer

const STAT_AMOUNT_BOX := preload("uid://baa3wachk2q7f")

func _ready() -> void:
	_set_main_stats()
	_set_skills()
	_set_defs()

func _set_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		_set_new_box(stat, main_stat_container)

func _set_new_box(stat:int, container:Control) -> void:
	var new_box:StatAmountBox = STAT_AMOUNT_BOX.instantiate()
	new_box.stat_name_label.hide()
	new_box.set_stat(stat)
	container.add_child(new_box)

func _set_defs() -> void:
	for stat:Stats.Defence in Stats.Defence.values():
		_set_new_box(stat, def_container)
	
func _set_skills() -> void:
	for stat:Stats.SkillStat in Stats.SkillStat.values():
		_set_new_box(stat, skill_container)
