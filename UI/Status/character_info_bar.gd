extends Control
class_name CharacterInfoBar

@export var status_container: HBoxContainer = null
@export var name_label: Label = null
@export var level_label: Label = null
@export var hp_bar: ProgressBar = null

const STATUS_PANEL := preload("uid://ckjtakb74tlm2")

var game_char:GameCharacter = null
var show_amount:int = 0
var is_hovered:bool = false
var show_pressed:bool = false
var disabled:bool = false

func _ready() -> void:
	if get_parent() is GameCharacter: set_game_character(get_parent())
	_connect_signals()

func disable(_parent_char:GameCharacter) -> void:
	disabled = true
	hide()
	set_process(false)
	GlobalSignals.show_info_bar.disconnect(_show_pressed.bind(true))
	GlobalSignals.hide_info_bar.disconnect(_show_pressed.bind(false))

func _show_pressed(pressed:bool) -> void:
	show_pressed = pressed
	if show_pressed or is_hovered: show_info()
	else: hide()
	
func _char_hovered(hovered:bool) -> void:
	is_hovered = hovered
	if show_pressed or is_hovered: show_info()
	else: hide()

func _change_show_amount(amount:int) -> void:
	show_amount += amount
	
	if show_amount > 0: show_info()
	else: hide()

func _connect_signals() -> void:
	game_char.died.connect(disable)
	GlobalSignals.show_info_bar.connect(_show_pressed.bind(true))
	GlobalSignals.hide_info_bar.connect(_show_pressed.bind(false))

func set_game_character(new_gc:GameCharacter):
	game_char = new_gc
	game_char.infobar = self
	
	game_char.status_handler.status_added.connect(_add_status)
	game_char.stat_handler.stats_changed.connect(_update_info)
	_update_info()
	
	game_char.character_mouse_over.connect(_char_hovered.bind(true))
	game_char.character_mouse_left.connect(_char_hovered.bind(false))
	
func _update_info() -> void:
	var level:String = "Lvl " + str(game_char.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL))
	level_label.text = level
	name_label.text = game_char.display_name
	
	hp_bar.value = game_char.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP)
	hp_bar.max_value = game_char.stat_handler.get_stat_amount(Stats.ResourceStat.MAX_HP)

func _add_status(new_status:Status):
	var new_spanel:StatusPanel = STATUS_PANEL.instantiate()
	new_status.remove_status.connect(_remove_status.bind(new_spanel))
	status_container.add_child(new_spanel)
	new_spanel.set_status(new_status)
	
func _remove_status(status_panel:StatusPanel):
	status_container.remove_child(status_panel)
	status_panel.queue_free()

func _process(_delta: float) -> void:
	if self.visible == false:
		set_process(false)
		return
	
	_set_screen_position()

func _set_screen_position() -> void:
	if !game_char:
		return
	
	var current_camera:Camera3D =  get_viewport().get_camera_3d()
	var screen_position:Vector2 = current_camera.unproject_position(game_char.heigth_node.global_transform.origin)
	var offset:Vector2 = Vector2(-self.size.x / 2, -self.size.y)
	self.global_position = screen_position + offset

func show_info() -> void:
	if disabled: return
	set_process(true)
	self.visible = true
