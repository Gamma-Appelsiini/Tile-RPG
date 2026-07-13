extends Node3D
class_name CameraHandler

signal camera_switched
signal camera_move_finished

@export var tactical_camera: TacticalCamera = null
@export var combat_camera: CombatCamera = null
@export var player_camera: PlayerCamera = null

const SWITCH_TIME:float = 0.5

var active_camera:PlayerCamera = null
var in_combat:bool = false
var switch_camera:Camera3D = Camera3D.new()

func _ready() -> void:
	add_child(switch_camera)
	set_process_input(false)
	active_camera = player_camera
	
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)
	GlobalSignals.change_to_override_cam.connect(_switch_to_override_cam)
	GlobalSignals.change_off_override_cam.connect(_switch_from_override_cam)

func _switch_to_override_cam(override_cam:Camera3D) -> void:
	active_camera.disactivate_camera()
	switch_to_camera(override_cam)
	GlobalSignals.player.player_camera = override_cam

func _switch_from_override_cam() -> void:
	switch_to_camera(active_camera.camera_3d)
	await camera_switched
	active_camera.set_as_active_camera()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Tactical View"):
		_tactical_camera_switch()

func _tactical_camera_switch() -> void:
	set_process_input(false)
	
	if active_camera == combat_camera:
		combat_camera.disactivate_camera()
		tactical_camera.global_position = combat_camera.global_position

		var rounded_y: float = roundf(rad_to_deg(combat_camera.pivot.rotation.y) / 90.0) * 90.0
		tactical_camera.pivot.rotation.y = deg_to_rad(rounded_y)
		switch_to_camera(tactical_camera.camera_3d)
		
		await camera_switched
		tactical_camera.set_as_active_camera()
		active_camera = tactical_camera
	else:
		tactical_camera.disactivate_camera()
		combat_camera.global_position = tactical_camera.global_position
		
		var rounded_y: float = roundf(rad_to_deg(tactical_camera.pivot.rotation.y) / 45.0) * 45.0
		combat_camera.pivot.rotation.y = deg_to_rad(rounded_y)
		switch_to_camera(combat_camera.camera_3d)
		
		await camera_switched
		combat_camera.set_as_active_camera()
		active_camera = combat_camera
	
	if in_combat: set_process_input(true)

func _on_combat_start() -> void:
	in_combat = true
	player_camera.disactivate_camera()
	await _switch_to_combat_camera()
	combat_camera.set_as_active_camera()
	set_process_input(true)
	camera_switched.emit()

func _on_combat_end() -> void:
	in_combat = false
	
	combat_camera.disactivate_camera()
	tactical_camera.disactivate_camera()
	
	var rounded_y: float = roundf(rad_to_deg(active_camera.pivot.rotation.y) / 45.0) * 45.0
	player_camera.pivot.rotation.y = deg_to_rad(rounded_y)
	
	await switch_to_camera(player_camera.camera_3d)
	
	player_camera.set_as_active_camera()
	active_camera = player_camera

func switch_to_camera(new_camera:Camera3D) -> void:
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	
	switch_camera.global_transform = current_camera.global_transform
	switch_camera.fov = current_camera.fov
	switch_camera.environment = current_camera.environment
	switch_camera.attributes = current_camera.attributes
	switch_camera.cull_mask = current_camera.cull_mask
	
	switch_camera.top_level = true
	switch_camera.force_update_transform()
	await get_tree().create_timer(0.05).timeout
	switch_camera.make_current()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(switch_camera, "global_transform", new_camera.global_transform, SWITCH_TIME)
	tween.tween_property(switch_camera, "fov", new_camera.fov, SWITCH_TIME)
	tween.tween_property(switch_camera, "v_offset", new_camera.v_offset, SWITCH_TIME)
	
	await tween.finished
	new_camera.make_current()
	
	camera_switched.emit()

func _switch_to_combat_camera() -> void:
	combat_camera.top_level = false
	combat_camera.pivot.transform = player_camera.pivot.transform
	combat_camera.global_transform = player_camera.global_transform
	
	var new_combat_camera:Camera3D = combat_camera.camera_3d
	new_combat_camera.cull_mask = player_camera.camera_3d.cull_mask
	new_combat_camera.fov = player_camera.camera_3d.fov
	new_combat_camera.transform = player_camera.camera_3d.transform
	new_combat_camera.v_offset = player_camera.camera_3d.v_offset

	combat_camera.force_update_transform()
	combat_camera.pivot.force_update_transform()
	new_combat_camera.force_update_transform()

	await get_tree().create_timer(1.5).timeout
	new_combat_camera.make_current()
	active_camera = combat_camera
	
	camera_switched.emit()
	
func handle_turn_camera(current_actor:GameCharacter) -> void:
	combat_camera.set_process(false)
	combat_camera.reparent(current_actor)
	_move_camera_to_char(current_actor)
	await camera_move_finished
	
	if current_actor is Player:
		combat_camera.top_level = true
		combat_camera.set_process(true)
	else:
		combat_camera.top_level = false
		
	camera_move_finished.emit()

func _move_camera_to_char(current_actor:GameCharacter) -> void:
	var distance:float = current_actor.global_position.distance_to(combat_camera.global_position)
	var time_to_point:float = distance * 0.2 + 0.2
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(combat_camera, "global_position", current_actor.global_position, time_to_point)
	await tween.finished
	camera_move_finished.emit()

func save_to_data(save_data:Dictionary) -> void:
	var cam_data:Dictionary = {
		"camera_transform": player_camera.camera_3d.transform,
		"transform": player_camera.transform,
		"pivot": player_camera.pivot.transform
	}
	save_data["camera"] = cam_data

func load_from_data(save_data:Dictionary) -> void:
	if !save_data.has("camera"): return
	var cam_data:Dictionary = save_data["camera"]
	
	player_camera.camera_3d.transform = cam_data["camera_transform"]
	player_camera.transform = cam_data["transform"]
	player_camera.pivot.transform = cam_data["pivot"]
	
