extends CenterContainer
class_name DmgNumber

@export var lifetime: float = 1.1
@export var float_distance: float = 46.0
@export var max_horizontal_drift: float = 14.0
@onready var number_label: Label = %NumberLabel

const TAKE_DAMAGE_MATERIAL := preload("uid://b72rjc52ql4wf")

var offset:Vector3 = Vector3(0.5,1.5,0.5)
var number_material:ShaderMaterial = TAKE_DAMAGE_MATERIAL.duplicate()
var position_node:Node3D = null
var free_to_use:bool = true

func _ready() -> void:
	set_process(false)
	number_label.material = number_material
	number_material.set_shader_parameter("seed", randf())
	number_material.set_shader_parameter("progress", 0.0)
	number_material.set_shader_parameter("is_crit", false)
	number_material.set_shader_parameter("float_distance", float_distance)
	number_material.set_shader_parameter("drift_x", randf_range(-max_horizontal_drift, max_horizontal_drift))

func _process(_delta: float) -> void:
	
	var screen_position:Vector2 = get_viewport().get_camera_3d().unproject_position(position_node.global_transform.origin + offset)
	self.global_position = screen_position
	
	if number_material.get_shader_parameter("progress") == lifetime:
		set_process(false)
		free_to_use = true

func setup(value: int, target_node:Node3D, is_crit: bool = false) -> void:
	offset = Vector3(randf_range(-0.2,0.2),randf_range(1.45,1.85),randf_range(-0.2,0.2))
	free_to_use = false
	position_node = target_node
	set_process(true)
	number_label.text = str(value)
 
	if is_crit:
		number_label.text += "!"
		add_theme_font_size_override("font_size", int(get_theme_font_size("font_size") * 1.35))
 
	number_material.set_shader_parameter("is_crit", is_crit)
 
	_play()
 
func _play() -> void:
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, lifetime).set_trans(Tween.TRANS_LINEAR)
 
func _set_progress(p: float) -> void:
	number_material.set_shader_parameter("progress", p)
