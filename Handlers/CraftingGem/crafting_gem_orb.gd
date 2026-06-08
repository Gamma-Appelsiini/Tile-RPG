extends RigidBody3D
class_name CraftingGemOrb

@export var gem_mesh: MeshInstance3D = null
@export var gem_pickup_sound:AudioStream = null
@export var gem_drop_sound:AudioStream = null
@export var particles: CPUParticles3D = null
@export var collision_shape_3d: CollisionShape3D = null

const EXPLOSION_SPEED:float = 6

var _bezier_t: float = 0.0
var _bezier_duration: float = 0.8
var _bezier_start: Vector3 = Vector3(0,0,0)
var _bezier_control: Vector3 = Vector3(0,0,0)
var _bezier_end: Vector3 = Vector3(0,0,0)

func _ready() -> void:
	set_process(false)
	top_level = true
	freeze = true

func _process(delta: float) -> void:
	_move_with_curve(delta)

func _move_with_curve(delta: float) -> void:
	_bezier_t += delta / _bezier_duration
	var t = clamp(_bezier_t, 0.0, 1.0)

	global_position = _quadratic_bezier(_bezier_start, _bezier_control, _bezier_end, t)

	if t >= 1.0:
		set_process(false)
		_on_pickup()

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	return (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * p1 + t * t * p2

func _move_to_target()-> void:
	set_process(true)
	collision_shape_3d.disabled = true
	self.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze_mode = FREEZE_MODE_STATIC
	freeze = true
	
	_bezier_t = 0.0
	_bezier_start = global_position
	_bezier_end = GlobalSignals.player.global_position + Vector3(0,1.5,0)

func shoot_gem() -> void:
	freeze = false
	var vel:Vector3 = (self.global_transform.origin - GlobalSignals.player.global_transform.origin) * EXPLOSION_SPEED
	self.linear_velocity = vel
	GlobalSignals.play_audio.emit(gem_drop_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	
	await get_tree().create_timer(2.5).timeout
	_move_to_target()

func _on_pickup()-> void:
	GlobalSignals.play_audio.emit(gem_pickup_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	GlobalSignals.ui_handler.inventory.player_gems += 1
	_delete_gem()

func _delete_gem()-> void:
	self.freeze = true
	freeze_mode = FREEZE_MODE_STATIC
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(gem_mesh,"scale",Vector3(0.01,0.01,0.01), .1)
	await tween.finished
	
	particles.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
