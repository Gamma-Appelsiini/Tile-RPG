extends Control
class_name DamageNumber

@export var number_label:Label = null

const DURATION:float = 1.5
const DAMAGE_NUMBER_MATERIAL := preload("uid://fe40pih55fp1")
const DAMAGE_NUMBER_GRADIENT := preload("uid://b7uj8f4tclini")
const OUTLINE_SIZE:int = 7
const FONT_SIZE:int = 55
const UP_HEIGHT:float = 100

var offset:Vector3 = Vector3(0.5,1.5,0.5)
var position_node:Node3D = null
var damage_material:ShaderMaterial = DAMAGE_NUMBER_MATERIAL.duplicate()
var free_to_use:bool = true
var up_offset:float = 0

func _ready() -> void:
	hide()
	number_label.material = damage_material
	set_process(false)

func spawn_text_at_node(new_text:String, target_pos:Node3D, font_color:Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	self.position_node = target_pos
	number_label.text = new_text
	
	number_label.add_theme_color_override("font_outline_color", Color(0.065, 0.006, 0.0, 1.0))
	number_label.add_theme_color_override("font_color", font_color)
	
	offset = Vector3(randf_range(-0.2,0.2),randf_range(1.45,1.85),randf_range(-0.2,0.2))
	set_process(true)
	_animate_label()

func _reset_visuals() -> void:
	up_offset = 0
	modulate.a = 1
	number_label.position = Vector2(0,0)
	scale = Vector2(0,0)
	
	number_label.add_theme_font_size_override("font_size", FONT_SIZE)
	damage_material.set_shader_parameter("is_crit", false)
	damage_material.set_shader_parameter("gradient_texture", DAMAGE_NUMBER_GRADIENT)
	number_label.add_theme_constant_override("outline_size", OUTLINE_SIZE)

func spawn_at_node(number:int, target_pos:Node3D, crit:bool = false) -> void:
	free_to_use = false
	_reset_visuals()
	
	self.position_node = target_pos
	number_label.text = str(number)
	#TODO get height
	offset = Vector3(randf_range(-0.2,0.2),randf_range(1.45,1.85),randf_range(-0.2,0.2))
	set_process(true)
	show()
	
	if crit: _handle_crit()
	_animate_label()

func _handle_crit() -> void:
	number_label.add_theme_font_size_override("font_size", FONT_SIZE + 7)
	damage_material.set_shader_parameter("gradient_texture", DAMAGE_NUMBER_GRADIENT)
	number_label.add_theme_constant_override("outline_size", OUTLINE_SIZE + 3)
	damage_material.set_shader_parameter("is_crit", true)

func _process(_delta: float) -> void:
	var screen_position:Vector2 = get_viewport().get_camera_3d().unproject_position(position_node.global_transform.origin + offset)
	self.global_position = screen_position - Vector2(0,up_offset)

func _animate_label() -> void:
	var offset_tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	offset_tween.tween_property(self,"up_offset", UP_HEIGHT, DURATION)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self,"scale",Vector2(1,1), 0.8)
	await tween.finished
	await get_tree().create_timer(0.4).timeout
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_parallel(true).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",0, 0.5)
	tween.tween_property(self,"scale",Vector2(0,0), 0.3)
	await tween.finished
	
	set_process(false)
	hide()
	free_to_use = true
