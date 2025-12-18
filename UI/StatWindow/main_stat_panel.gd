extends PanelContainer
class_name MainStatPanel

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var grid_container: GridContainer = %GridContainer

const ADD_BUTTON := preload("uid://dcbb1hnpi8h6l")
const MAIN_STAT_TOOLTIP := preload("uid://j8qvwulhgpwq")

var STAT_LINE_PATH:String = "res://Tile-RPG/UI/StatWindow/main_stat_line.tscn"
var stat_label_dict:Dictionary[Stats.MainStat, Label] = {}
var buttons:Array[XButton] = []
var asd:int = 249223

func set_stat_hanlder(sh:StatHandler) -> void:
	sh.leveled_up.connect(_show_buttons.bind(sh))
	sh.stats_changed.connect(_update_stats.bind(sh))

func fill_main_stats() -> void:
	for stat:Stats.MainStat in Stats.MainStat.values():
		var new_stat_line:StatLine = load(STAT_LINE_PATH).instantiate()
		new_stat_line.set_stat(stat,1)
		grid_container.add_child(new_stat_line)
		_add_stat_tooltip(new_stat_line)
		
		var lab:Label = new_stat_line.number_label
		new_stat_line.remove_child(lab)
		grid_container.add_child(lab)
		stat_label_dict[stat] = lab
		
		_new_add_button(stat)

func _add_stat_tooltip(stat_line:StatLine) -> void:
	var new_tt:MainStatTooltip = MAIN_STAT_TOOLTIP.instantiate()
	new_tt.stat_name.text = EnumStrings.MAIN_STAT_NAMES[stat_line.line_stat_type]
	new_tt.stat_desc.text = EnumStrings.MAIN_STAT_SCALING[stat_line.line_stat_type]
	new_tt.stat_flavor.text = EnumStrings.MAIN_STAT_DESCRIPTIONS[stat_line.line_stat_type]
	stat_line.stat_pic.add_child(new_tt)
	
	stat_line.mouse_entered.connect(new_tt.show_tooltip)
	stat_line.mouse_exited.connect(new_tt.hide)

func _new_add_button(stat:Stats.MainStat) -> void:
	var new_button:XButton = ADD_BUTTON.instantiate()
	new_button.modulate.a = 0
	grid_container.add_child(new_button)
	new_button.x_pressed.connect(_increase_player_stat.bind(stat))
	buttons.push_back(new_button)

func _increase_player_stat(stat:Stats.MainStat) -> void:
	var player:Player = GlobalSignals.player
	if player.stat_handler.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) == 0: return
	
	player.stat_handler.update_stat(Stats.CharStat.STATS_TO_ALLOCATE, -1)
	player.stat_handler.update_stat(stat, 1)
	
	if player.stat_handler.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) == 0:
		for abutton:XButton in buttons: abutton.modulate.a = 0

func _show_buttons(sh:StatHandler) -> void:
	if sh.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) > 0:
		for abutton:XButton in buttons: abutton.modulate.a = 1

func _update_stats(sh:StatHandler) -> void:
	for stat:Stats.MainStat in stat_label_dict.keys():
		stat_label_dict[stat].text = str(sh.main_stats[stat])
