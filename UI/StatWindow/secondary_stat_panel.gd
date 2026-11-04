extends MarginContainer
class_name SecondaryStatsPanel

@export var stats_container: VBoxContainer
@export var hbox_container: HBoxContainer
@export var stat_label: Label
@export var number_label: Label

var stats_dict:Dictionary[int, Label] = {}

func _ready() -> void:
	show()
	_set_stats()
	await get_tree().process_frame
	hide()

func _set_stats() -> void:
	var sorted_stats: Array = Stats.SecondaryStat.values()
	sorted_stats.sort_custom(_sort_by_label)
	
	for stat:int in sorted_stats:
		stat_label.text = EnumStrings.SECONDARY_NAMES[stat]
		
		var new_container:HBoxContainer = hbox_container.duplicate()
		stats_container.add_child(new_container)
		new_container.show()
		stats_dict[stat] = new_container.get_child(1)
		
func update_stats(stat_handler:StatHandler) -> void:
	for stat:int in stats_dict.keys():
		stats_dict[stat].text = str(stat_handler.get_stat_amount(stat))

func _sort_by_label(a: int, b: int) -> bool:
	return EnumStrings.SECONDARY_NAMES[a].naturalnocasecmp_to(EnumStrings.SECONDARY_NAMES[b]) < 0
