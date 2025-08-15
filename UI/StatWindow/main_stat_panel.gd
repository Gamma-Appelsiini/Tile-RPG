extends PanelContainer
class_name MainStatPanel

@onready var v_box_container: VBoxContainer = %VBoxContainer
var STAT_LINE_PATH:String = "res://Tile-RPG/UI/StatWindow/main_stat_line.tscn"

func fill_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_stat_line:StatLine = load(STAT_LINE_PATH).instantiate()
		new_stat_line.set_stat(stat,1)
		v_box_container.add_child(new_stat_line)
		

func update_stats(sh:StatHandler) -> void:
	for child in v_box_container.get_children():
		if child is StatLine:
			child.update_value(sh.main_stats[child.line_stat_type])
