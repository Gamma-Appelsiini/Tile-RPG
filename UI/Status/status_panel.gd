extends Control
class_name StatusPanel

signal delete_status_panel

@export var status_pic: TextureRect = null
@export var texture_rect: TextureRect = null
@export var panel_container: PanelContainer = null
@export var duration_bar: ProgressBar = null

const COLOR_RECT_SHADER := preload("uid://ckbqgufh8hftd")
const STATUS_TOOLTIP = preload("uid://bwhs2cbh0fab4")

var status:Status = null
var shader_material:ShaderMaterial = null
var s_tooltip:StatusTooltip = null

func set_status(new_status:Status) -> void:
	status = new_status
	status_pic.texture = new_status.picture
	
	if new_status.status_type == Status.STATUS_TYPE.DEBUFF:
		texture_rect.self_modulate = "ff0008"
		duration_bar.self_modulate = "ff0008"
		
	_add_tt()
	panel_container.mouse_entered.connect(func(): s_tooltip._show_tt())
	panel_container.mouse_exited.connect(func(): s_tooltip.hide())
	
	status.duration_changed.connect(_set_shadow_rect)
	_set_shadow_rect()

func _add_tt() -> void:
	s_tooltip = STATUS_TOOLTIP.instantiate()
	s_tooltip.set_status(status)
	add_child(s_tooltip)
	s_tooltip.hide()

func _set_shadow_rect() -> void:
	var cur_d:int = status.current_duration
	var max_d:int = status.max_duration
	duration_bar.value = cur_d
	duration_bar.max_value = max_d
	
	if cur_d <= 0: _delete_status_panel()

func _delete_status_panel() -> void:
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0, 2)
	
	await tween.finished
	delete_status_panel.emit()
	
