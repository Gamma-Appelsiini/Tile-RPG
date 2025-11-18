extends Control
class_name StatusPanel

@onready var shadow_rect: ColorRect = $PanelContainer/ShadowRect

const COLOR_RECT_SHADER := preload("uid://ckbqgufh8hftd")

var status:Status = null
var shader_material:ShaderMaterial = null

func _ready() -> void:
	shadow_rect.material = COLOR_RECT_SHADER.duplicate()
	shader_material = shadow_rect.material

func set_status(new_status:Status) -> void:
	status = new_status
	status.duration_changed.connect(_set_shadow_rect)

func _set_shadow_rect() -> void:
	var cur_d:int = status.current_duration
	var max_d:int = status.max_duration
	
	var percentage:float = cur_d / float(max_d)
	percentage = abs(1 - percentage)
	shader_material.set_shader_parameter("percentage", percentage)
