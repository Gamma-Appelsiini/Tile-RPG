extends Control
class_name CharacterInfoBar

@export var status_container: GridContainer = null
@export var name_label: Label = null
@export var level_label: Label = null
@export var hp_bar: ProgressBar = null

const STATUS_PANEL := preload("uid://ckjtakb74tlm2")

var game_char:GameCharacter = null
var show_amount:int = 0
var disabled:bool = false

func _ready() -> void:
	if get_parent() is GameCharacter: set_game_character(get_parent())
	_connect_signals()

func disable(_parent_char:GameCharacter) -> void:
	disabled = true
	hide()
	set_physics_process(false)
	GlobalSignals.show_info_bar.disconnect(_change_show_amount.bind(1))
	GlobalSignals.hide_info_bar.disconnect(_change_show_amount.bind(-1))

func _on_window_defocus() -> void:
	show_amount = 0
	hide()

func _change_show_amount(amount:int) -> void:
	show_amount += amount
	
	if show_amount > 0: show_info()
	else: hide()

func _connect_signals() -> void:
	game_char.died.connect(disable)
	GlobalSignals.show_info_bar.connect(_change_show_amount.bind(1))
	GlobalSignals.hide_info_bar.connect(_change_show_amount.bind(-1))
	get_window().focus_exited.connect(_on_window_defocus)

func set_game_character(new_gc:GameCharacter):
	game_char = new_gc
	game_char.infobar = self
	
	game_char.status_handler.status_added.connect(_add_status)
	game_char.stat_handler.stats_changed.connect(_update_info)
	_update_info()
	
	game_char.character_mouse_over.connect(_change_show_amount.bind(1))
	game_char.character_mouse_left.connect(_change_show_amount.bind(-1))
	
func _update_info() -> void:
	var level:String = "Lvl " + str(game_char.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL))
	level_label.text = level
	name_label.text = game_char.display_name
	
	hp_bar.value = game_char.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP)
	hp_bar.max_value = game_char.stat_handler.get_stat_amount(Stats.ResourceStat.MAX_HP)

func _add_status(new_status:Status):
	var new_spanel:StatusPanel = STATUS_PANEL.instantiate()
	new_status.remove_status.connect(_remove_status_panel.bind(new_spanel))
	status_container.add_child(new_spanel)
	new_spanel.set_status(new_status)
	
func _remove_status_panel(status_panel:StatusPanel) -> void:
	if status_panel.get_parent() == status_container:
		status_container.remove_child(status_panel)
	status_panel.queue_free()

func _physics_process(_delta: float) -> void:
	if self.visible == false:
		set_physics_process(false)
		return
	
	_set_screen_position()

func _set_screen_position() -> void:
	if !game_char:
		return

	var current_camera: Camera3D = get_viewport().get_camera_3d()
	if !current_camera:
		return

	var screen_position: Vector2 = current_camera.unproject_position(
		game_char.heigth_node.global_transform.origin
	)

	var offset := Vector2(-size.x / 2.0, -size.y)
	var final_position := screen_position + offset
	var viewport_size := get_viewport_rect().size
	
	# How far outside the viewport are we?
	var out_left := maxf(0.0, -final_position.x)
	var out_top := maxf(0.0, -final_position.y)
	var out_right := maxf(0.0, final_position.x + size.x - viewport_size.x)
	var out_bottom := maxf(0.0, final_position.y + size.y - viewport_size.y)

	var max_outside := maxf(
		maxf(out_left, out_right),
		maxf(out_top, out_bottom)
	)
	const HIDE_DISTANCE:float = 200
	if max_outside > HIDE_DISTANCE:
		modulate.a = 0
		return

	modulate.a = 1

	final_position.x = clamp(final_position.x, 0.0, viewport_size.x - size.x)
	final_position.y = clamp(final_position.y, 0.0, viewport_size.y - size.y)

	global_position = final_position

func show_info() -> void:
	if disabled: return
	set_physics_process(true)
	self.visible = true
