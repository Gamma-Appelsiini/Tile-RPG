extends Node3D
class_name TreeHalf

const SKILL_ORB := preload("uid://beisi558iqap8")

const SKILL_SPOTS:Dictionary[Vector3, Vector3] = {
	Vector3(0.124142, 0.300618, 0.187238): Vector3(0.32532, 0.498879, 0.803297),
	Vector3(0.284796, 0.113188, 0.195747): Vector3(0.634175, 0.261225, 0.727725),
	Vector3(0.253152, -0.131444, 0.187447): Vector3(0.591832, -0.37269, 0.714729),
	Vector3(0.001217, -0.248283, 0.195235): Vector3(0.0, -0.632535, 0.774532),
	Vector3(-0.238547, -0.142398, 0.193829): Vector3(-0.591832, -0.37269, 0.714729),
	Vector3(-0.279927, 0.116839, 0.198678): Vector3(-0.634175, 0.261226, 0.727725),
	Vector3(-0.111971, 0.300618, 0.192166): Vector3(-0.32532, 0.498879, 0.803297),
	Vector3(0.0, 0.0, 0.3): Vector3(0.0, 0.0, 1.0),
}

func _ready() -> void:
	_set_orbs()

func _set_orbs() -> void:
	for spot:Vector3 in SKILL_SPOTS.keys():
		var new_orb:Node3D = SKILL_ORB.instantiate()
		add_child(new_orb)
		new_orb.position = spot
		var alignment_quat:Quaternion = Quaternion(Vector3.UP, SKILL_SPOTS[spot])
		new_orb.transform.basis = Basis(alignment_quat)
