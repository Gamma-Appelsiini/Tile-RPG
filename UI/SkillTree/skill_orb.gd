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
var connectors:Array[MeshInstance3D] = []
var connector_area:Area3D = null
var learned:bool = false

func set_skill_resource(new_skill:SkillResource) -> void:
	_handle_connections(new_skill)

	if new_skill == null:
		hide()
		return
	else: show()
	
	skill_in_orb = new_skill
	var unlearned_material:ShaderMaterial = UNLEARNED_SKILL_ORB_MATERIAL.duplicate()
	unlearned_material.set_shader_parameter("skill_texture", new_skill.skill_picture)
	orb.material_override = unlearned_material
	
	learned = false

	if new_skill.learned:
		learn_skill(true)
		learned = true
	else:
		_reset_learned_appearance()

func _reset_learned_appearance() -> void:
	crack_decal.hide()
	sparkles.emitting = false
	smoke_column.hide()
	orb.material_overlay = null

func _handle_connections(new_skill:SkillResource) -> void:
	for connector_mesh:MeshInstance3D in connectors:
		var transparency_amount:float = 1.0
		
		if new_skill == null:
			transparency_amount = 0
			if connector_area: connector_area.hide()
		elif new_skill.get_connected_tree_page():
			if learned or !new_skill.requires_learning_for_traversal: connector_area.show()
		else:
			transparency_amount = 0
			if connector_area: connector_area.hide()
		
		var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(connector_mesh, "transparency", transparency_amount,1.25)
		await tween.finished
		for mesh:MeshInstance3D in connectors:
			mesh.material_overlay = null

func _tween_crack_decal() -> void:
	crack_decal.show()
	crack_decal.rotation_degrees.y = randf_range(0,360)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	tween.tween_property(crack_decal, "albedo_mix", 0.5, 2)
	tween.tween_property(crack_decal, "albedo_mix", 0.01, 2)

func learn_skill(without_animation:bool = false) -> void:
	if learned: return
	learned = true
	
	if !without_animation:
		GlobalSignals.play_audio.emit(learn_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
		smoke_column.scale = Vector3(1,0.01,1)
		smoke_column.show()
		var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(smoke_column, "scale", Vector3(1,1,1), 0.25)
		rocks.emitting = true
		
	_tween_crack_decal()
	
	var learned_material:ShaderMaterial = LEARNED_SKILL_ORB_MATERIAL.duplicate()
	learned_material.set_shader_parameter("skill_texture", skill_in_orb.skill_picture)
	learned_material.set_shader_parameter("primary_color", Color(EnumStrings.MAIN_STAT_COLORS[skill_in_orb.skill_stat_type]))
	orb.material_override = learned_material
	orb.material_overlay = OUTER_MATERIAL
	
	for mesh:MeshInstance3D in connectors:
		mesh.material_overlay = OUTER_MATERIAL
	
	sparkles.emitting = true
	smoke_column.show()
	crack_decal.show()
	
	if skill_in_orb.get_connected_tree_page():
		if connector_area: connector_area.show()
