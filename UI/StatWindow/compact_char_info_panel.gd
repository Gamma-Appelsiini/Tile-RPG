extends PanelContainer
class_name CompactStatsPanel

@onready var main_stat_container: GridContainer = $HBoxContainer/MainStatContainer
@onready var def_container: GridContainer = $HBoxContainer/VBoxContainer/DefContainer
@onready var skill_container: HBoxContainer = $HBoxContainer/VBoxContainer/SkillContainer

const STAT_AMOUNT_BOX := preload("uid://baa3wachk2q7f")
var game_char:GameCharacter = null
var hide_infobar:bool = false
var all_containers:Array[Control] = []

func _process(_delta: float) -> void:
	if !visible:
		set_process(false)
		return
	
	_set_screen_position()

func _on_vis_change() -> void:
	if visible:
		_update_stats()
		game_char.stat_handler.stats_changed.connect(_update_stats)
		set_process(true)
	else:
		game_char.stat_handler.stats_changed.disconnect(_update_stats)
		if hide_infobar:
			hide_infobar = false
			game_char.infobar._change_show_amount(-1)

func _set_screen_position() -> void:
	if !game_char:
		hide()
		return

	if game_char.infobar.modulate.a == 0:
		modulate.a = 0
		return
		
	if !game_char.infobar.visible:
		hide_infobar = true
		game_char.infobar._change_show_amount(1)
	
	modulate.a = 1
	var screen_position: Vector2 = game_char.infobar.global_position
	var is_on_top_side := screen_position.y + size.y * 0.5 > get_viewport().get_visible_rect().size.y * 0.5
	var offset := Vector2(0, game_char.infobar.size.y)
	#left_arrow.show()
	#right_arrow.hide()
	
	if is_on_top_side:
		offset = Vector2(0, -size.y / 2)
		#left_arrow.hide()
		#right_arrow.show()
	
	var target_position := screen_position + offset
	global_position = target_position

func _ready() -> void:
	_set_main_stats()
	_set_skills()
	_set_defs()
	visibility_changed.connect(_on_vis_change)
	all_containers = [main_stat_container, def_container, skill_container]
	set_process(false)

func set_character(new_character:GameCharacter) -> void:
	game_char = new_character

func _update_stats() -> void:
	for container:Control in all_containers:
		for child:Control in container.get_children():
			if child is StatAmountBox:
				child.update_amount(game_char.stat_handler.get_stat_amount(child.stat))

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
