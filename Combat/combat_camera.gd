extends PlayerCamera
class_name CombatCamera

const MAX_DISTANCE:float = 20

var camera_speed:float = 3
var parent_node:Node3D = null

func _ready() -> void:
	parent_node = get_parent_node_3d()
	pivot = parent_node

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	if move_direction != Vector3.ZERO:
		var new_pos := parent_node.global_position + move_direction * camera_speed * delta
		var offset := new_pos - self.global_position
		var dist := offset.length()

		if dist > MAX_DISTANCE:
			offset = offset.normalized() * MAX_DISTANCE
			new_pos = self.global_position + offset

		parent_node.global_position = new_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate_Cam_L"):
		_rotate_cam(-90)
	elif event.is_action_pressed("Rotate_Cam_R"):
		_rotate_cam(90)
	elif event.is_action_pressed("roll_up"):
		_zoom_cam(-1)
	elif event.is_action_pressed("roll_down"):
		_zoom_cam(1)

func _distance_to_parent() -> float:
	return self.global_position.distance_to(parent_node.global_position)

func _handle_movement_input() -> Vector3:
	var direction:Vector3 = Vector3.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := self.global_basis.z
	var right := self.global_basis.x
	
	direction = forward * raw_input.y + right * raw_input.x
	
	return direction
