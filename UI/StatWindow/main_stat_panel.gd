extends PanelContainer
class_name MainStatPanel

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var grid_container: GridContainer = %GridContainer

var STAT_LINE_PATH:String = "res://Tile-RPG/UI/StatWindow/main_stat_line.tscn"
var stat_label_dict:Dictionary[Stats.MainStat, Label] = {}

func fill_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_stat_line:StatLine = load(STAT_LINE_PATH).instantiate()
		new_stat_line.set_stat(stat,1)
		grid_container.add_child(new_stat_line)
		
		var lab:Label = new_stat_line.number_label
		new_stat_line.remove_child(lab)
		grid_container.add_child(lab)
		stat_label_dict[stat] = lab

func update_stats(sh:StatHandler) -> void:
	for stat:Stats.MainStat in stat_label_dict.keys():
		stat_label_dict[stat].text = str(sh.main_stats[stat])


func _on_button_pressed() -> void:
	GlobalSignals.change_all_stats_visibility.emit()
