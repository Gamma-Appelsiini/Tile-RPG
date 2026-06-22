extends Node3D
class_name CameraHandler

signal camera_switched
signal camera_move_finished

@export var tactical_camera: TacticalCamera = null
@export var combat_camera: CombatCamera = null
@export var player_camera: PlayerCamera = null

const SWITCH_TIME:float = 0.5

var active_camera:Node3D = null
var in_combat:bool = false

func _ready() -> void:
	set_process_input(false)
	active_camera = player_camera
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Tactical View"):
		_tactical_camera_switch()

func _tactical_camera_switch() -> void:
	set_process_input(false)
	
	if active_camera == combat_camera:
		combat_camera.disactivate_camera()
		var rounded_y: float = roundf(combat_camera.pivot.rotation.y / 90.0) * 90.0
		tactical_camera.pivot.rotation.y = rounded_y
		switch_to_camera(tactical_camera.camera_3d)
		
		await camera_switched
		tactical_camera.set_as_active_camera()
		active_camera = tactical_camera
	else:
		tactical_camera.disactivate_camera()
		var rounded_y: float = roundf(tactical_camera.pivot.rotation.y / 45.0) * 45.0
		combat_camera.pivot.rotation.y = rounded_y
		switch_to_camera(combat_camera.camera_3d)
		
		await camera_switched
		combat_camera.set_as_active_camera()
		active_camera = combat_camera
	
	if in_combat: set_process_input(true)

func _on_combat_start() -> void:
	in_combat = true
	
	player_camera.disactivate_camera()
	_switch_to_combat_camera()
	
	await get_tree().create_timer(1).timeout
	combat_camera.set_as_active_camera()
	set_process_input(true)

func _on_combat_end() -> void:
	in_combat = false
	
	combat_camera.disactivate_camera()
	tactical_camera.disactivate_camera()
	await switch_to_camera(player_camera.camera_3d)
	
	player_camera.set_as_active_camera()
	active_camera = player_camera

func switch_to_camera(new_camera:Camera3D) -> void:
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	var switch_camera:Camera3D = Camera3D.new()
	
	add_child(switch_camera)
	switch_camera.global_transform = current_camera.global_transform
	switch_camera.fov = current_camera.fov
	switch_camera.environment = current_camera.environment
	switch_camera.attributes = current_camera.attributes
	switch_camera.cull_mask = current_camera.cull_mask
	
	switch_camera.top_level = true
	switch_camera.make_current()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(switch_camera, "global_transform", new_camera.global_transform, SWITCH_TIME)
	tween.tween_property(switch_camera, "fov", new_camera.fov, SWITCH_TIME)
	
	await tween.finished
	new_camera.make_current()
	switch_camera.queue_free()
	
	camera_switched.emit()

func _switch_to_combat_camera() -> void:
	combat_camera.pivot.transform = player_camera.pivot.transform
	combat_camera.global_position = player_camera.global_position
	
	var new_combat_camera:Camera3D = combat_camera.camera_3d
	new_combat_camera.cull_mask = player_camera.camera_3d.cull_mask
	new_combat_camera.fov = player_camera.camera_3d.fov
	new_combat_camera.transform = player_camera.camera_3d.transform
	
	#await get_tree().create_timer(0.1).timeout
	combat_camera.camera_3d.make_current()
	active_camera = combat_camera
	
func _handle_camera(current_actor:GameCharacter) -> void:
	combat_camera.reparent(current_actor)
	_move_camera_to_char(current_actor)
	await camera_move_finished
	
	if current_actor is Player:
		pass
	else:
		pass

func _move_camera_to_char(current_actor:GameCharacter) -> void:
	var distance:float = current_actor.global_position.distance_to(combat_camera.global_position)
	var time_to_point:float = distance * 0.2 + 0.2
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(combat_camera, "global_position", current_actor.global_position, time_to_point)
	await tween.finished
	camera_move_finished.emit()
