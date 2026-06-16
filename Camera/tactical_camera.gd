extends CombatCamera
class_name TacticalCamera

@export var move_node: Node3D = null

const MAX_DISTANCE:float = 100

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	if move_direction != Vector3.ZERO:
		var new_pos := self.global_position + move_direction * camera_speed * delta
		var offset := new_pos - self.global_position
		var dist := offset.length()

		if dist > MAX_DISTANCE:
			offset = offset.normalized() * MAX_DISTANCE
			new_pos = self.global_position + offset

		self.global_position = new_pos
	
#Overrided
func _rotate_cam(amount:float) -> void:
	if rotating: return
	rotating = true
	
	var rotation_time:float = 0.25
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera_3d,"rotation:y",camera_3d.rotation.y + deg_to_rad(amount), rotation_time)
	
	await tween.finished
	rotating = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Cam L"):
		_rotate_cam(-90)
	elif event.is_action_pressed("Rotate Cam R"):
		_rotate_cam(90)
	elif event.is_action_pressed("Zoom In"):
		_move_camera(true)
	elif event.is_action_pressed("Zoom Out"):
		_move_camera(false)

#Overrided
func _move_camera(towards: bool)-> void:
	const MAX_ZOOM_IN:float = -5
	const MAX_ZOOM_OUT:float = 50
	const MOVE_AMOUNT: float = 2
	
	var dir:float = 1
	if towards: dir = -1
	
	var final_pos:float = clamp(camera_3d.position.y + MOVE_AMOUNT * dir, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(camera_3d, "position:y", final_pos, 0.1)
