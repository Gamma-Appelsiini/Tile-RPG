extends PlayerCamera
class_name CombatCamera

var camera_speed:float = 3
var parent_node:Node3D = null

func _ready() -> void:
	set_process_input(false)
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	if move_direction != Vector3.ZERO:
		var new_pos := global_position + move_direction * camera_speed * delta
		global_position = new_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Cam L"):
		_rotate_cam(-90)
	elif event.is_action_pressed("Rotate Cam R"):
		_rotate_cam(90)
	elif event.is_action_pressed("Zoom In"):
		_move_camera(true)
	elif event.is_action_pressed("Zoom Out"):
		_move_camera(false)

func _distance_to_parent() -> float:
	return self.global_position.distance_to(parent_node.global_position)

func _handle_movement_input() -> Vector3:
	var direction:Vector3 = Vector3.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := self.global_basis.z
	var right := self.global_basis.x
	
	direction = forward * raw_input.y + right * raw_input.x
	
	return direction
