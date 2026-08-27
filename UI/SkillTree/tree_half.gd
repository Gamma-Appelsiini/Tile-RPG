extends Node3D
class_name TreeHalf

const SKILL_ORB := preload("uid://beisi558iqap8")
@onready var scene_camera: Camera3D = $Camera3D
@export var tree_mesh: MeshInstance3D = null
@export var hover_zoom_distance: float = 0.4
@export var hover_sound:AudioStream = null

const GEM_SKILL_SPOTS:Dictionary[Vector3, Vector3] = {
	Vector3(0.124142, 0.300618, 0.187238): Vector3(0.32532, 0.498879, 0.803297),
	Vector3(0.284796, 0.113188, 0.195747): Vector3(0.634175, 0.261225, 0.727725),
	Vector3(0.253152, -0.131444, 0.187447): Vector3(0.591832, -0.37269, 0.714729),
	Vector3(0.001217, -0.248283, 0.195235): Vector3(0.0, -0.632535, 0.774532),
	Vector3(-0.238547, -0.142398, 0.193829): Vector3(-0.591832, -0.37269, 0.714729),
	Vector3(-0.279927, 0.116839, 0.198678): Vector3(-0.634175, 0.261226, 0.727725),
	Vector3(-0.111971, 0.300618, 0.192166): Vector3(-0.32532, 0.498879, 0.803297),
	Vector3(0.0, 0.025, 0.3): Vector3(0.0, 0.0, 1.0),
}

const SPHERE_SKILL_SPOTS:Dictionary[Vector3, Vector3] = {
	Vector3(0.0, 0.363544, 0.342084): Vector3(0, 0.300618, 0.287238),
	Vector3(0.284536, 0.230411, 0.337937): Vector3(0.592275, 0.441632, 0.673923),
	Vector3(0.360268, -0.079053, 0.335222): Vector3(0.736575, -0.19598, 0.64734),
	Vector3(0.16012, -0.332211, 0.335271): Vector3(0.331877, -0.658819, 0.675141),
	Vector3(-0.156872, -0.32784, 0.341094): Vector3(-0.333555, -0.658759, 0.674372),
	Vector3(-0.358103, -0.081113, 0.337103): Vector3(-0.736816, -0.194368, 0.647551),
	Vector3(-0.289944, 0.231578, 0.332488): Vector3(-0.591017, 0.44168, 0.674995),
	Vector3(0.0, 0.0, 0.5): Vector3(0.0, 0.0, 1.0),
}

var orbs:Array[SkillOrb] = []
var _hover_tween: Tween
var _base_mesh_pos: Vector3

func _ready() -> void:
	if tree_mesh:
		_base_mesh_pos = tree_mesh.position
	_set_orbs()

func _set_orbs() -> void:
	for spot:Vector3 in SPHERE_SKILL_SPOTS.keys():
		var new_orb:SkillOrb = SKILL_ORB.instantiate()
		tree_mesh.add_child(new_orb)
		new_orb.position = spot
		var alignment_quat:Quaternion = Quaternion(Vector3.UP, SPHERE_SKILL_SPOTS[spot])
		new_orb.transform.basis = Basis(alignment_quat)
		orbs.push_back(new_orb)
		new_orb.enter_area_3d.mouse_entered.connect(_on_orb_hovered.bind(new_orb))
		new_orb.enter_area_3d.mouse_exited.connect(_on_orb_exited.bind(new_orb))

func _on_orb_hovered(orb: SkillOrb) -> void:
	GlobalSignals.play_audio.emit(hover_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	const ROTATE_AMOUNT: float = 0.65
	var target_dir := orb.position.normalized()
	var target_quat := Quaternion(target_dir, Vector3.BACK)
	var final_quat := Quaternion.IDENTITY.slerp(target_quat, ROTATE_AMOUNT)
	
	var original_orb_pos := orb.position 
	var rotated_orb_pos := final_quat * orb.position
	var compensation_offset := original_orb_pos - rotated_orb_pos
	
	var orb_global := orb.global_position
	var cam_global := scene_camera.global_position
	var dir_to_cam := (cam_global - orb_global).normalized()
	
	var zoom_amount:float = hover_zoom_distance
	if orb.position == Vector3(0.0, 0.0, 0.5): zoom_amount = 0.1
	var zoom_target_global := orb_global + (dir_to_cam * zoom_amount)
	var local_zoom_offset := to_local(zoom_target_global) - to_local(orb_global)
	
	var final_pos := _base_mesh_pos + compensation_offset + local_zoom_offset
	
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(tree_mesh, "quaternion", final_quat, 0.2)
	_hover_tween.tween_property(tree_mesh, "position", final_pos, 0.2)


func _on_orb_exited(_orb: SkillOrb) -> void:
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(tree_mesh, "quaternion", Quaternion.IDENTITY, 0.2)
	_hover_tween.tween_property(tree_mesh, "position", _base_mesh_pos, 0.2)

func _process(_delta: float) -> void:
	for orb:SkillOrb in orbs:
		orb.orb.look_at(scene_camera.global_position)
