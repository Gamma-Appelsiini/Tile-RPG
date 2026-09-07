extends Node3D
class_name TreeHalf

const SKILL_ORB := preload("uid://beisi558iqap8")
@onready var scene_camera: Camera3D = $Camera3D
@export var tree_mesh: MeshInstance3D = null
@export var hover_zoom_distance: float = 0.4
@export var hover_sound:AudioStream = null
@export var front_connectors: Node3D = null
@export var back_connectors: Node3D = null
@export var rotators: Node3D = null
@export var back_orbs_parent: Node3D = null

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

var current_orbs:Array[SkillOrb] = []
var front_orbs:Array[SkillOrb] = []
var back_orbs:Array[SkillOrb] = []
var _hover_tween: Tween
var _base_mesh_pos: Vector3
var hovered_orb:SkillOrb = null
var hovered_area:Area3D = null
var front:bool = true
var front_resource:SkillTreeResource = null
var back_resource:SkillTreeResource = null
var save_data:Dictionary = {}
var rotating_disabled:bool = false
var orb_in_hover_reserve:SkillOrb = null
var _rest_quat: Quaternion = Quaternion.IDENTITY
var front_rotator_area_dict:Dictionary[Area3D, SkillOrb] = {}
var back_rotator_area_dict:Dictionary[Area3D, SkillOrb] = {}

func set_tree_resource(tree_resource:SkillTreeResource) -> void:
	if front: front_resource = tree_resource
	else: back_resource = tree_resource
	
	for spot:int in tree_resource.skills_in_tree.keys():
		var skill_orb:SkillOrb = current_orbs[spot]
		skill_orb.set_skill_resource(tree_resource.skills_in_tree[spot])
		skill_orb.enter_area_3d.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_mouse_pressed()

func _mouse_pressed() -> void:
	if hovered_orb: hovered_orb.learn_skill()
	elif hovered_area: _rotate_to_other_side()

func _ready() -> void:
	if tree_mesh:
		_base_mesh_pos = tree_mesh.position
	_set_orbs()
	_add_rotators()
	const START_PAGE_RESOURCE := preload("uid://etai7p3sm21x")
	set_tree_resource(START_PAGE_RESOURCE)

func _create_orb(spot:Vector3, number:int, back:bool = false) -> SkillOrb:
	var new_orb:SkillOrb = SKILL_ORB.instantiate()
	
	if back:
		new_orb.name = "Back Orb " + str(number)
		back_orbs_parent.add_child(new_orb)
		back_orbs.push_back(new_orb)
	else:
		new_orb.name = "Front Orb " + str(number)
		tree_mesh.add_child(new_orb)
		front_orbs.push_back(new_orb)
	
	new_orb.position = spot
	var alignment_quat:Quaternion = Quaternion(Vector3.UP, SPHERE_SKILL_SPOTS[spot])
	new_orb.transform.basis = Basis(alignment_quat)
	new_orb.enter_area_3d.mouse_entered.connect(_on_orb_hovered.bind(new_orb))
	new_orb.enter_area_3d.mouse_exited.connect(_on_orb_exited.bind(new_orb))
	return new_orb

func _set_orbs() -> void:
	var number:int = 0
	for spot:Vector3 in SPHERE_SKILL_SPOTS.keys():
		var new_orb:SkillOrb = _create_orb(spot, number)
		var new_back_orb:SkillOrb = _create_orb(spot, number, true)
		
		#Middle of sphere with no connections
		if number == 7: continue
		
		new_orb.connectors.push_back(front_connectors.get_children()[number])
		new_orb.connectors.push_back(back_connectors.get_children()[number])
		
		var back_spot:int = number
		if back_spot != 0: back_spot = len(back_connectors.get_children()) - number
		new_back_orb.connectors.push_back(front_connectors.get_children()[back_spot])
		new_back_orb.connectors.push_back(back_connectors.get_children()[back_spot])
		
		var linked_area:Area3D = rotators.get_children()[number] as Area3D
		front_rotator_area_dict[linked_area] = new_orb
		new_orb.connector_area = linked_area
		
		#0=0, 1=6, 2=5, 3=4,4=3,5=2, 6=1
		back_spot = number
		if back_spot != 0: back_spot = len(rotators.get_children()) - (number)
		new_back_orb.connector_area = rotators.get_children()[back_spot]
		back_rotator_area_dict[new_back_orb.connector_area] = new_back_orb
		
		number += 1
	
	back_orbs_parent.rotation_degrees.y = 180
	current_orbs = front_orbs

func _add_rotators() -> void:
	for area:Area3D in rotators.get_children():
		area.mouse_entered.connect(_on_connector_entered.bind(area))
		area.mouse_exited.connect(_on_connector_exited.bind(area))

func _on_connector_entered(area:Area3D) -> void:
	hovered_area = area
	
func _on_connector_exited(_area:Area3D) -> void:
	hovered_area = null

func _rotate_to_other_side() -> void:
	if rotating_disabled: return
	rotating_disabled = true
	
	var connecting_orb:SkillOrb = null
	if front:
		connecting_orb = front_rotator_area_dict[hovered_area]
	else:
		connecting_orb = back_rotator_area_dict[hovered_area]
	
	if !connecting_orb.skill_in_orb:
		print_debug("NO SKILL IN ORB: ", connecting_orb)
		rotating_disabled = false
		return
	
	var next_tree_resource:SkillTreeResource = connecting_orb.skill_in_orb.get_connected_tree_page()
	if !next_tree_resource: return
	
	for orb in current_orbs:
		orb.enter_area_3d.hide()
	
	if front:
		front_resource.save_to_data(save_data)
		current_orbs = back_orbs
		back_resource = front_resource
	else:
		back_resource.save_to_data(save_data)
		current_orbs = front_orbs
		front_resource = back_resource

	next_tree_resource.load_from_data(save_data)
	set_tree_resource(next_tree_resource)
	
	_animate_tree_rotation(connecting_orb)

func _animate_tree_rotation(connecting_orb: SkillOrb) -> void:
	if _hover_tween: 
		_hover_tween.kill()

	var target_quat := Quaternion.IDENTITY

	if front:
		var dir := Vector2(connecting_orb.position.x, connecting_orb.position.y)

		if dir.length_squared() > 0.001:
			dir = dir.normalized()
			var axis := Vector3(dir.y, -dir.x, 0).normalized()
			target_quat = Quaternion(axis, deg_to_rad(179.99))
		else:
			target_quat = Quaternion(Vector3.DOWN, deg_to_rad(179.99))

	front = !front
	_rest_quat = target_quat

	_hover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).set_parallel()
	_hover_tween.tween_property(tree_mesh, "quaternion", target_quat, 1.0)
	_hover_tween.tween_property(tree_mesh, "position", Vector3(0, 0, 0), .5)

	await _hover_tween.finished
	rotating_disabled = false

	if orb_in_hover_reserve: 
		_on_orb_hovered(orb_in_hover_reserve)


func _zoom_in_on_orb(orb: SkillOrb) -> void:
	var rest_quat := _rest_quat
	var rest_transform := Transform3D(Basis(rest_quat), _base_mesh_pos)

	var local_orb_pos := rest_transform.affine_inverse() * orb.global_position
	var local_cam_pos := rest_transform.affine_inverse() * scene_camera.global_position
	var local_cam_dir := local_cam_pos.normalized()

	const ROTATE_AMOUNT: float = 0.65
	var target_quat := Quaternion(local_orb_pos.normalized(), local_cam_dir)
	var tilt_quat := Quaternion.IDENTITY.slerp(target_quat, ROTATE_AMOUNT)

	var final_quat := rest_quat * tilt_quat

	var compensation_offset := (rest_quat * local_orb_pos) - (final_quat * local_orb_pos)

	var orb_global := orb.global_position
	var cam_global := scene_camera.global_position
	var dir_to_cam := (cam_global - orb_global).normalized()

	var zoom_amount: float = hover_zoom_distance
	if orb.position == Vector3(0.0, 0.0, 0.5):
		zoom_amount = 0.1

	var zoom_target_global := orb_global + (dir_to_cam * zoom_amount)
	var local_zoom_offset := to_local(zoom_target_global) - to_local(orb_global)

	var final_pos := _base_mesh_pos + compensation_offset + local_zoom_offset

	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()

	_hover_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(tree_mesh, "quaternion", final_quat, 0.2)
	_hover_tween.tween_property(tree_mesh, "position", final_pos, 0.2)


func _on_orb_exited(_orb: SkillOrb) -> void:
	if rotating_disabled or !hovered_orb:
		orb_in_hover_reserve = null
		return

	orb_in_hover_reserve = null
	hovered_orb = null
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()

	_hover_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(tree_mesh, "quaternion", _rest_quat, 0.2)
	_hover_tween.tween_property(tree_mesh, "position", _base_mesh_pos, 0.2)

func _on_orb_hovered(orb: SkillOrb) -> void:
	if rotating_disabled:
		orb_in_hover_reserve = orb
		return
		
	orb_in_hover_reserve = null
	hovered_orb = orb
	GlobalSignals.play_audio.emit(hover_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	_zoom_in_on_orb(hovered_orb)

func _process(_delta: float) -> void:
	for orb:SkillOrb in current_orbs:
		orb.orb.look_at(scene_camera.global_position)
