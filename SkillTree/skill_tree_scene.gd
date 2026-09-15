extends Node3D
class_name SkillTreeScene

@onready var camera_3d: Camera3D = $Camera3D
@onready var eater_model: CharacterModelHandler = $EaterModel
@onready var feeding_gem: Node3D = $FeedingGem
@onready var crack_decal: Decal = $CrackDecal
@onready var crack_decal_2: Decal = $CrackDecal2
@onready var smoke: GPUParticles3D = $Smoke
@onready var dirt: GPUParticles3D = $Dirt

var held_gem:Node3D = null
var look_at_helper:Node3D = null
var last_gem_pos:Vector3 = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_grab_gem()
	elif event.is_action_released("Left Click"):
		_throw_gem()

func _process(_delta: float) -> void:
	_cam_follow_mouse()
	_position_gem_at_mouse()
	
func _cam_follow_mouse() -> void:
	const FOLLOW_AMOUNT: float = 0.1
	const MAX_TILT_DEGREES: float = 5.0
	const BASE_ROTATION: Vector3 = Vector3(-30.0, 0.0, 0.0)
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size == Vector2.ZERO:
		return
		
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var center_offset: Vector2 = (mouse_pos / viewport_size) - Vector2(0.5, 0.5)
	
	var target_rotation: Vector3 = Vector3(
		BASE_ROTATION.x - (center_offset.y * MAX_TILT_DEGREES),
		BASE_ROTATION.y - (center_offset.x * MAX_TILT_DEGREES),
		0.0
	)
	
	camera_3d.rotation_degrees = camera_3d.rotation_degrees.lerp(target_rotation, FOLLOW_AMOUNT)

func _ready() -> void:
	set_process_input(false)
	_zoom_camera_in()
	_move_eater_to_place()
	look_at_helper = Node3D.new()
	add_child(look_at_helper)

func _position_gem_at_mouse() -> void:
	if !held_gem: return
	
	const SPHERE_DIAMETER: float = 2.4
	var radius: float = SPHERE_DIAMETER / 2.0

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_dir: Vector3 = camera_3d.project_ray_normal(mouse_pos)

	held_gem.global_position = camera_3d.global_position + (ray_dir * radius)
	
	_rotate_gem()

func _rotate_gem() -> void:
	var displacement: Vector3 = held_gem.global_position - last_gem_pos
	var delta: float = get_process_delta_time()

	var tilt_strength: float = 30.0
	var target_down: Vector3 = (Vector3.DOWN - displacement * tilt_strength).normalized()
	var target_rotation: Quaternion = Quaternion(Vector3.DOWN, target_down)

	var sway_speed: float = 12.0
	held_gem.quaternion = held_gem.quaternion.slerp(target_rotation, sway_speed * delta)
	
	last_gem_pos = held_gem.global_position

func _zoom_camera_in() -> void:
	const CAM_FINAL_POS:Vector3 = Vector3(0,1,2)
	const CAM_FINAL_ROTATION:Vector3 = Vector3(-30,0,0)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(camera_3d, "position", CAM_FINAL_POS, 2)
	tween.tween_property(camera_3d, "rotation_degrees", CAM_FINAL_ROTATION, 1.5)
	
	await tween.finished
	set_process(true)

func _grab_gem() -> void:
	held_gem = feeding_gem.duplicate()
	add_child(held_gem)
	held_gem.show()
	eater_model.play_unique_animation("mouth_open", false, false, 0.2)
	eater_model.set_target_to_look_at(held_gem)

func _look_at_helper(wait_time:float, gem:Node3D) -> void:
	await get_tree().create_timer(wait_time).timeout
	look_at_helper.global_position = gem.global_position
	eater_model.set_target_to_look_at(look_at_helper)

func _throw_gem() -> void:
	var thrown_gem:Node3D = held_gem
	held_gem = null
	
	const AIR_TIME:float = 0.4
	const ARC_HEIGHT:float = .5
	_look_at_helper(AIR_TIME / 2, thrown_gem)
	
	var start_pos:Vector3 = thrown_gem.global_position
	var target_pos:Vector3 = eater_model.head_node.global_position
	
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(thrown_gem, "rotation_degrees", thrown_gem.rotation_degrees + Vector3(randf_range(15,100),randf_range(15,100),randf_range(15,100)), AIR_TIME)
	tween.tween_property(thrown_gem, "global_position:x", target_pos.x, AIR_TIME).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(thrown_gem, "global_position:z", target_pos.z, AIR_TIME).set_trans(Tween.TRANS_LINEAR)
	
	var y_tween:Tween = create_tween()
	var peak_y:float = max(start_pos.y, target_pos.y) + ARC_HEIGHT
	
	y_tween.tween_property(thrown_gem, "global_position:y", peak_y, AIR_TIME / 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	y_tween.tween_property(thrown_gem, "global_position:y", target_pos.y, AIR_TIME / 2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	_eat_gem(thrown_gem)

func _eat_gem(thrown_gem:Node3D) -> void:
	eater_model.play_unique_animation("eat")
	eater_model.stop_looking_at_target()
	await get_tree().create_timer(0.15).timeout
	thrown_gem.queue_free()
	
	await eater_model.animation_player.animation_finished
	_remove_eater()

func _move_eater_to_place() -> void:
	eater_model.play_animation(CharacterModelHandler.CharAnimation.WALK, false)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(eater_model, "position", Vector3(0,0,0),4)
	
	await tween.finished
	eater_model.play_idle_animation()
	set_process_input(true)

func _remove_eater() -> void:
	eater_model.play_unique_animation("burrow", false)
	await get_tree().create_timer(0.72).timeout
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_parallel()
	tween.tween_property(crack_decal, "albedo_mix", 1, 0.2)
	tween.tween_property(crack_decal_2, "albedo_mix", 1, 0.2)
	smoke.emitting = true
	dirt.emitting = true
	_spawn_skill_sphere()

func _spawn_skill_sphere() -> void:
	pass
