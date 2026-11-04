extends MarginContainer
class_name DefencesContainer

@export var use_resistances:bool = false
@export var stats_container: GridContainer

const STAT_PANEL := preload("uid://cs0lekbgmxbn6")

var stat_panels:Array[StatPanel] = []

func _ready() -> void:
	_set_stats()
	
func _set_stats() -> void:
	var array_to_use:Array = Stats.Defence.values()
	if use_resistances: array_to_use = Stats.DmgType.values()
	
	for stat:int in array_to_use:
		if stat == Stats.DmgType.PURE: continue
		
		var new_stat_panel:StatPanel = STAT_PANEL.instantiate()
		new_stat_panel.set_stat(stat)
		stats_container.add_child(new_stat_panel)
		stat_panels.push_back(new_stat_panel)

func update_stats(stat_handler:StatHandler) -> void:
	for stat_panel:StatPanel in stat_panels:
		stat_panel.update_amount(stat_handler)
