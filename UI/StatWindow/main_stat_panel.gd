extends PanelContainer
class_name MainStatPanel

@onready var v_box_container: VBoxContainer = %VBoxContainer
var STAT_LINE_PATH:String = "res://Tile-RPG/UI/StatWindow/main_stat_line.tscn"

func fill_main_stats(sh:StatHandler):
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_stat_line:StatLine = load(STAT_LINE_PATH).instantiate()
		v_box_container.add_child(new_stat_line)
		new_stat_line.set_stat(stat,sh.main_stats[stat])
		
