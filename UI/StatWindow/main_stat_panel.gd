extends PanelContainer
class_name MainStatPanel

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var grid_container: GridContainer = %GridContainer

const ADD_BUTTON := preload("uid://dcbb1hnpi8h6l")

var STAT_LINE_PATH:String = "res://Tile-RPG/UI/StatWindow/main_stat_line.tscn"
var stat_label_dict:Dictionary[Stats.MainStat, Label] = {}
var buttons:Array[XButton] = []

func fill_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_stat_line:StatLine = load(STAT_LINE_PATH).instantiate()
		new_stat_line.set_stat(stat,1)
		grid_container.add_child(new_stat_line)
		
		var lab:Label = new_stat_line.number_label
		new_stat_line.remove_child(lab)
		grid_container.add_child(lab)
		stat_label_dict[stat] = lab
		
		_new_add_button(stat)

func _new_add_button(stat:Stats.MainStat) -> void:
	var new_button:XButton = ADD_BUTTON.instantiate()
	new_button.self_modulate.a = 0
	#new_button.size = Vector2(35,35)
	grid_container.add_child(new_button)
	new_button.x_pressed.connect(_increase_player_stat.bind(stat))

func _increase_player_stat(stat:Stats.MainStat) -> void:
	var player:Player = GlobalSignals.player
	if player.stat_handler.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) == 0: return
	
	player.stat_handler.update_stat(Stats.CharStat.STATS_TO_ALLOCATE, -1)
	player.stat_handler.update_stat(stat, 1)
	
	if player.stat_handler.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) == 0:
		for abutton:XButton in buttons: abutton.self_modulate.a = 0

func update_stats(sh:StatHandler) -> void:
	if sh.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) > 0:
		for abutton:XButton in buttons: abutton.self_modulate.a = 1
	
	for stat:Stats.MainStat in stat_label_dict.keys():
		stat_label_dict[stat].text = str(sh.main_stats[stat])
