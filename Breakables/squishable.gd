extends Node3D
class_name Squishable

@export var model:MeshInstance3D = null
@export var squish_texture:Texture2D = null
@export var decal:Decal = null
@export var area:Area3D = null
@export var squish_sound:AudioStream = null

var start_pos:Vector3 = Vector3.INF
var moving:bool = true
var moving_legs:bool = false
var blend_shape_value:float = 1
var tween:Tween
var shape_key_tween:Tween

func _ready() -> void:
	start_pos = global_position
	decal.texture_albedo = squish_texture
	area.body_entered.connect(_squish)
	_move()

func _move() -> void:
	if !moving: return
	
	moving_legs = true
	_move_legs()
	var next_pos:Vector3 = Vector3(randf_range(-.5,.5),0,randf_range(-.5,.5)) + start_pos
	self.look_at(next_pos)
	
	tween = create_tween()
	tween.tween_property(self, "global_position", next_pos, 2 * global_position.distance_to(next_pos))
	await tween.finished
	shape_key_tween.stop()
	moving_legs = false
	
	await get_tree().create_timer(randf_range(1,6)).timeout
	_move()

func _move_legs() -> void:
	if !moving_legs: return
	
	shape_key_tween = create_tween()
	shape_key_tween.tween_property(model, "blend_shapes/Move", blend_shape_value, 0.15)
	await shape_key_tween.finished
	
	if blend_shape_value == 1: blend_shape_value = 0
	else: blend_shape_value = 1
	
	_move_legs()

func _squish(body:Node3D) -> void:
	if body is not GameCharacter: return
	
	GlobalSignals.play_audio.emit(squish_sound,AudioManager.AUDIO_TYPE.SOUND_EFFECT,global_position)
	shape_key_tween.stop()
	tween.stop()
	
	area.set_deferred("monitoring", false)
	moving = false
	decal.visible = true
	model.visible = false
	await get_tree().create_timer(3).timeout
	
	tween = create_tween()
	tween.tween_property(decal, "modulate:a", 0, 1.0)
	await tween.finished
	
	queue_free()
