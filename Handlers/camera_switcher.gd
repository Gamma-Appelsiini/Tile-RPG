class_name CameraSwitcher

const SWITCH_TIME:float = 0.3

static func switch_to_camera(new_camera:Camera3D) -> void:
	var current_camera:Camera3D = GlobalSignals.player.get_viewport().get_camera_3d()
	var switch_camera:Camera3D = current_camera.duplicate()
	
	current_camera.get_parent().add_child(switch_camera)
	switch_camera.global_position = current_camera.global_position
	switch_camera.top_level = true
	switch_camera.current = true
	
	var tween:Tween = GlobalSignals.player.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(switch_camera, "transform", new_camera.transform, SWITCH_TIME)
	tween.tween_property(switch_camera, "fov", new_camera.fov, SWITCH_TIME)
	
	await tween.finished
	new_camera.current = true
	switch_camera.queue_free()
