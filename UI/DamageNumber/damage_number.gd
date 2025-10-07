extends Control
class_name DamageNumber

@export var number_label:Label = null

const DURATION:float = 1.5

var offset:Vector3 = Vector3(0.5,1.5,0.5)
var game_camera:Camera3D = null
var position_node:Node3D = null

func _ready() -> void:
	set_process(false)
	number_label.scale = Vector2(0,0)

func spawn_text_at_node(new_text:String, target_pos:Node3D) -> void:
	self.position_node = target_pos
	game_camera = GlobalSignals.player.player_camera
	number_label.text = new_text
	
	number_label.add_theme_color_override("font_outline_color", Color(0.913, 0.298, 0.0, 1.0))
	number_label.add_theme_color_override("font_color", Color(0.0, 0.643, 0.9, 1.0))
	
	offset = Vector3(randf_range(-0.2,0.2),randf_range(1.45,1.85),randf_range(-0.2,0.2))
	set_process(true)
	_animate_label()

func spawn_at_node(number:int, target_pos:Node3D, crit:bool = false) -> void:
	self.position_node = target_pos
	game_camera = GlobalSignals.player.player_camera
	number_label.text = str(number)
	
	offset = Vector3(randf_range(-0.2,0.2),randf_range(1.45,1.85),randf_range(-0.2,0.2))
	set_process(true)
	if crit: _handle_crit()
	_animate_label()

func _handle_crit() -> void:
	number_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 1.0))
	number_label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	number_label.add_theme_font_size_override("font_size", 62)

func _process(_delta: float) -> void:
	var screen_position:Vector2 = game_camera.unproject_position(position_node.global_transform.origin + offset)
	self.global_position = screen_position

func _animate_label() -> void:
	var tween2:Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween2.tween_property(number_label,"position", number_label.position + Vector2(0,-150), DURATION)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(number_label,"scale",Vector2(1.5,1.5), 0.2)
	await tween.finished
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(number_label,"scale",Vector2(1,1), 0.1)
	await tween2.finished
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(number_label,"modulate:a",0, 0.2)
	await tween.finished
	
	queue_free()
