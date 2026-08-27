extends Node3D
class_name SkillOrb

const LEARNED_MATERIAL:ShaderMaterial = preload("uid://kqhg8g1etiif")
const SKILL_ORB_MATERIAL:ShaderMaterial = preload("uid://y6cenuvcmwob")

@export var orb: MeshInstance3D = null
@export var enter_area_3d: Area3D = null
@export var learn_sound:AudioStream = null
@export var crack_decal: Decal = null
@export var sparkles: GPUParticles3D = null
@export var smoke_column: MeshInstance3D = null

func _ready() -> void:
	_tween_crack_decal()

func _tween_crack_decal() -> void:
	crack_decal.rotation_degrees.y = randf_range(0,360)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(crack_decal, "albedo_mix", 0.5, 2)
	tween.tween_property(crack_decal, "albedo_mix", 0.01, 2)

func learn_skill() -> void:
	GlobalSignals.play_audio.emit(learn_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	orb.material_overlay = LEARNED_MATERIAL
	sparkles.emitting = true
	smoke_column.scale = Vector3(1,0.01,1)
	smoke_column.show()
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(smoke_column, "scale", Vector3(1,1,1), 0.25)
	crack_decal.show()
