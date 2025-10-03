extends RigidBody3D
class_name XpOrb

@export var ball_mesh:MeshInstance3D = null
@export var collision_shape:CollisionShape3D = null
@export var xp_pick_sound:AudioStream = null
@export var particles:CPUParticles3D = null

const EPIC_MATERIAL = preload("uid://00flkueqj2ft")
const IRIDESCENT_MATERIAL = preload("uid://cniioqeusvqpk")
const RARE_MATERIAL = preload("uid://bch8hx8bqdg2r")
const COMMON_MATERIAL = preload("uid://cinmwl8lufsce")

const COMMON_RIM_MATERIAL = preload("uid://cvefy81ib74xm")
const RARE_RIM_MATERIAL = preload("uid://h40onvp801ju")
const EPIC_RIM_MATERIAL = preload("uid://13rok4y1hvvo")
const IRIDESCENT_RIM_MATERIAL = preload("uid://c0y1j817t4323")

const ORB_MATERIALS:Dictionary[int, ShaderMaterial] = {
	50: IRIDESCENT_MATERIAL,
	25: EPIC_MATERIAL,
	10: RARE_MATERIAL,
	1: COMMON_MATERIAL}

const ORB_RIMS:Dictionary[int, ShaderMaterial] = {
	50: IRIDESCENT_RIM_MATERIAL,
	25: EPIC_RIM_MATERIAL,
	10: RARE_RIM_MATERIAL,
	1: COMMON_RIM_MATERIAL}

const ORB_SIZES:Dictionary[int,float] ={
	50: 2,
	25: 1.5,
	10: 1,
	1: 0.5}

var moving:bool = false
var target:Node3D = null
var timer:Timer = null

var _bezier_t: float = 0.0
var _bezier_duration: float = 0.5
var _bezier_start: Vector3 = Vector3(0,0,0)
var _bezier_control: Vector3 = Vector3(0,0,0)
var _bezier_end: Vector3 = Vector3(0,0,0)

func _ready() -> void:
	top_level = true
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = randf_range(1.7,2.1)
	timer.one_shot = true
	timer.timeout.connect(_move_to_target)
	timer.start()

func set_params(orb_size:int, target_node:Node3D):	
	target = target_node
	collision_shape.scale = Vector3(ORB_SIZES[orb_size],ORB_SIZES[orb_size],ORB_SIZES[orb_size])
	ball_mesh.scale = Vector3(ORB_SIZES[orb_size],ORB_SIZES[orb_size],ORB_SIZES[orb_size])

	ball_mesh.material_override = ORB_MATERIALS[orb_size]
	ball_mesh.material_overlay = ORB_RIMS[orb_size]

func disappear():
	GlobalSignals.play_audio.emit(xp_pick_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	_tween_orb()

func _move_to_target(target_node:Node3D = target)-> void:
	collision_shape.disabled = true
	self.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze_mode = FREEZE_MODE_STATIC
	freeze = true
	target = target_node
	moving = true
	
	_bezier_t = 0.0
	_bezier_start = global_position
	_bezier_end = target.global_position

	var random_offset:Vector3 = Vector3(randf() - 0.5, randf() * 0.5, randf() - 0.5).normalized() * 2.0
	_bezier_control = (_bezier_start + _bezier_end) * 0.5 + random_offset

func _move_with_curve(delta: float) -> void:
	_bezier_t += delta / _bezier_duration
	var t = clamp(_bezier_t, 0.0, 1.0)

	global_position = _quadratic_bezier(_bezier_start, _bezier_control, _bezier_end, t)

	if t >= 1.0:
		moving = false
		disappear()

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	return (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * p1 + t * t * p2

func _tween_orb():
	self.freeze = true
	freeze_mode = FREEZE_MODE_STATIC
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(ball_mesh,"scale",Vector3(0.1,0.1,0.1), .1)
	await tween.finished
	
	particles.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
