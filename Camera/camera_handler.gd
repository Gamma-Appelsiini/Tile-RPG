extends Node3D
class_name CameraHandler

signal camera_switched

@export var tactical_camera: TacticalCamera = null
@export var combat_camera: CombatCamera = null
@export var player_camera: PlayerCamera = null

const SWITCH_TIME:float = 0.5

func _ready() -> void:
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)

func _on_combat_start() -> void:
	player_camera.disactivate_camera()
	_switch_to_combat_camera()
	await camera_switched
	
	combat_camera.set_as_active_camera()
	set_process_input(true)

func _on_combat_end() -> void:
	await switch_to_camera(player_camera.camera_3d)
	
	player_camera.set_as_active_camera()

func switch_to_camera(new_camera:Camera3D) -> void:
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	var switch_camera:Camera3D = current_camera.duplicate()
	
	current_camera.get_parent().add_child(switch_camera)
	switch_camera.global_position = current_camera.global_position
	switch_camera.top_level = true
	switch_camera.make_current()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(switch_camera, "transform", new_camera.transform, SWITCH_TIME)
	tween.tween_property(switch_camera, "fov", new_camera.fov, SWITCH_TIME)
	
	await tween.finished
	new_camera.make_current()
	switch_camera.queue_free()
	
	camera_switched.emit()

func _switch_to_combat_camera() -> void:
	combat_camera.pivot.transform = player_camera.pivot.transform
	combat_camera.global_position = player_camera.global_position
	combat_camera.make_current()
	
	#spectate_camera = player.player_camera.duplicate()
	#spectate_camera.set_script(CombatCamera)
	#spectate_camera.set_process_input(false)
	#spectate_camera.set_physics_process(false)
	#spectate_camera_pivot.add_child(spectate_camera)
	#add_child(spectate_camera_pivot)
	#spectate_camera_pivot.global_position = player.player_camera.get_parent().global_position
	
	
