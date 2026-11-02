extends MarginContainer
class_name MainStatsPanel

@export var stats_container: VBoxContainer

const MAIN_STAT_LINER := preload("uid://bkkmsv4r1jb0v")

func _ready() -> void:
	fill_main_stats()

func fill_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_main_stats_line:MainStatLiner = MAIN_STAT_LINER.instantiate()
		new_main_stats_line.set_stat(stat, 1)
		stats_container.add_child(new_main_stats_line)
