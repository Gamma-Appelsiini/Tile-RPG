extends RigidBody3D
class_name XpOrb

@export var ball_mesh:MeshInstance3D = null
@export var collision_shape:CollisionShape3D = null
@export var xp_pick_sound:AudioStream = null
@export var particles:CPUParticles3D = null
@export var curve_mover: CurveMover = null

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
	50: 3,
	25: 2,
	10: 1.5,
	1: 1}

var xp_amount:int = 0
var target:GameCharacter = null

func _ready() -> void:
	top_level = true
	await get_tree().create_timer(randf_range(1.7,2.1)).timeout
	_move_orb()

func _move_orb() -> void:
	curve_mover.target_reached.connect(disappear)
	curve_mover.move_to_target(self, GlobalSignals.player)

func set_params(orb_size:int, target_char:GameCharacter):
	xp_amount = orb_size
	target = target_char
	collision_shape.scale = Vector3(ORB_SIZES[orb_size],ORB_SIZES[orb_size],ORB_SIZES[orb_size])
	ball_mesh.scale = Vector3(ORB_SIZES[orb_size],ORB_SIZES[orb_size],ORB_SIZES[orb_size])

	ball_mesh.material_override = ORB_MATERIALS[orb_size]
	ball_mesh.material_overlay = ORB_RIMS[orb_size]

func disappear():
	GlobalSignals.play_audio.emit(xp_pick_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	target.stat_handler.add_xp(xp_amount)
	_tween_orb()

func _tween_orb():
	self.freeze = true
	freeze_mode = FREEZE_MODE_STATIC
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(ball_mesh,"scale",Vector3(0.1,0.1,0.1), .1)
	await tween.finished
	
	particles.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
