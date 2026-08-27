extends Node3D
class_name SkillOrb

const OUTER_MATERIAL:ShaderMaterial = preload("uid://kqhg8g1etiif")
const LEARNED_SKILL_ORB_MATERIAL:ShaderMaterial = preload("uid://y6cenuvcmwob")
const UNLEARNED_SKILL_ORB_MATERIAL:ShaderMaterial = preload("uid://d1c8dwfbxkp0f")

@export var orb: MeshInstance3D = null
@export var enter_area_3d: Area3D = null
@export var learn_sound:AudioStream = null
@export var crack_decal: Decal = null
@export var sparkles: GPUParticles3D = null
@export var smoke_column: MeshInstance3D = null
@export var rocks: GPUParticles3D = null

var skill_in_orb:SkillResource = null

func _ready() -> void:
	_tween_crack_decal()

func set_skill_resource(new_skill:SkillResource) -> void:
	skill_in_orb = new_skill
	
	var unlearned_material:ShaderMaterial = UNLEARNED_SKILL_ORB_MATERIAL.duplicate()
	unlearned_material.set_shader_parameter("shader_parameter/skill_texture", new_skill.skill_picture)
	orb.material_override = unlearned_material


func _tween_crack_decal() -> void:
	crack_decal.rotation_degrees.y = randf_range(0,360)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(crack_decal, "albedo_mix", 0.5, 2)
	tween.tween_property(crack_decal, "albedo_mix", 0.01, 2)

func learn_skill() -> void:
	GlobalSignals.play_audio.emit(learn_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	
	var learned_material:ShaderMaterial = LEARNED_SKILL_ORB_MATERIAL.duplicate()
	learned_material.set_shader_parameter("shader_parameter/skill_texture", skill_in_orb.skill_picture)
	learned_material.set_shader_parameter("shader_parameter/primary_color", EnumStrings.MAIN_STAT_COLORS[skill_in_orb.skill_stat_type])
	orb.material_override = learned_material
	
	orb.material_overlay = OUTER_MATERIAL
	sparkles.emitting = true
	rocks.emitting = true
	smoke_column.scale = Vector3(1,0.01,1)
	smoke_column.show()
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(smoke_column, "scale", Vector3(1,1,1), 0.25)
	crack_decal.show()
