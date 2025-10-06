extends Control
class_name DamageNumber

@export var number_label:Label = null

const DURATION:float = 2

var game_camera:Camera3D = null
var position_node:Node3D = null

func _ready() -> void:
	set_process(false)
	number_label.scale = Vector2(0,0)

func spawn_at_node(number:int, target_pos:Node3D) -> void:
	self.position_node = target_pos
	game_camera = GlobalSignals.player.player_camera
	number_label.text = str(number)
	
	set_process(true)
	_animate_label()

func _process(_delta: float) -> void:
	var screen_position:Vector2 = game_camera.unproject_position(position_node.global_transform.origin)
	self.global_position = screen_position

func _animate_label() -> void:
	var tween2:Tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween2.tween_property(number_label,"position", number_label.position + Vector2(1,1), DURATION)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(number_label,"scale",Vector2(1.5,1.5), 0.2)
	await tween.finished
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(number_label,"scale",Vector2(1,1), 0.1)
	await tween2.finished
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(number_label,"scale",Vector2(0,0), 0.1)
	await tween.finished
	
	queue_free()
