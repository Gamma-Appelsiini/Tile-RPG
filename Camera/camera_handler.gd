extends Node3D
class_name CameraHandler

@export var tactical_camera: TacticalCamera = null

const SWITCH_TIME:float = 0.3

func switch_to_camera(new_camera:Camera3D) -> void:
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	var switch_camera:Camera3D = current_camera.duplicate()
	
	current_camera.get_parent().add_child(switch_camera)
	switch_camera.global_position = current_camera.global_position
	switch_camera.top_level = true
	switch_camera.current = true
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(switch_camera, "transform", new_camera.transform, SWITCH_TIME)
	tween.tween_property(switch_camera, "fov", new_camera.fov, SWITCH_TIME)
	
	await tween.finished
	new_camera.current = true
	switch_camera.queue_free()

func _set_combat_camera() -> void:
	if spectate_camera_pivot: spectate_camera_pivot.queue_free()
	if spectate_camera: spectate_camera.queue_free()
	
	spectate_camera_pivot = player.player_camera.get_parent().duplicate()
	spectate_camera = player.player_camera.duplicate()
	spectate_camera.set_script(CombatCamera)
	spectate_camera.set_process_input(false)
	spectate_camera.set_physics_process(false)
	spectate_camera_pivot.add_child(spectate_camera)
	add_child(spectate_camera_pivot)
	spectate_camera_pivot.global_position = player.player_camera.get_parent().global_position
	
	spectate_camera.make_current()
