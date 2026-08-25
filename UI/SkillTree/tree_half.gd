extends Node3D
class_name TreeHalf

const SKILL_ORB := preload("uid://beisi558iqap8")
@onready var scene_camera: Camera3D = $Camera3D
@onready var gem_mesh: MeshInstance3D = $Gem

const SKILL_SPOTS:Dictionary[Vector3, Vector3] = {
	Vector3(0.124142, 0.300618, 0.187238): Vector3(0.32532, 0.498879, 0.803297),
	Vector3(0.284796, 0.113188, 0.195747): Vector3(0.634175, 0.261225, 0.727725),
	Vector3(0.253152, -0.131444, 0.187447): Vector3(0.591832, -0.37269, 0.714729),
	Vector3(0.001217, -0.248283, 0.195235): Vector3(0.0, -0.632535, 0.774532),
	Vector3(-0.238547, -0.142398, 0.193829): Vector3(-0.591832, -0.37269, 0.714729),
	Vector3(-0.279927, 0.116839, 0.198678): Vector3(-0.634175, 0.261226, 0.727725),
	Vector3(-0.111971, 0.300618, 0.192166): Vector3(-0.32532, 0.498879, 0.803297),
	Vector3(0.0, 0.025, 0.3): Vector3(0.0, 0.0, 1.0),
}

var orbs:Array[SkillOrb] = []

func _ready() -> void:
	_set_orbs()

func _set_orbs() -> void:
	for spot:Vector3 in SKILL_SPOTS.keys():
		var new_orb:SkillOrb = SKILL_ORB.instantiate()
		gem_mesh.add_child(new_orb)
		new_orb.position = spot
		var alignment_quat:Quaternion = Quaternion(Vector3.UP, SKILL_SPOTS[spot])
		new_orb.transform.basis = Basis(alignment_quat)
		orbs.push_back(new_orb)
		new_orb.area_3d.mouse_entered.connect(_on_orb_hovered.bind(new_orb))
		new_orb.area_3d.mouse_exited.connect(_on_orb_exited.bind(new_orb))

var _hover_tween: Tween

func _on_orb_hovered(orb: SkillOrb) -> void:
	const ROTATE_AMOUN: float = 0.5
	var target_dir := orb.position.normalized()
	var target_quat := Quaternion(target_dir, Vector3.BACK)
	var final_quat := Quaternion.IDENTITY.slerp(target_quat, ROTATE_AMOUN)
	
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(gem_mesh, "quaternion", final_quat, 0.2)

func _on_orb_exited(_orb: SkillOrb) -> void:
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
		
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(gem_mesh, "quaternion", Quaternion.IDENTITY, 0.2)

func _process(_delta: float) -> void:
	for orb:SkillOrb in orbs:
		orb.orb.look_at(scene_camera.global_position)
	
