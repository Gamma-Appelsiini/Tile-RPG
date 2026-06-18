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

func _handle_movement_input() -> Vector3:
	var direction:Vector3 = Vector3.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := pivot.global_basis.z
	var right := pivot.global_basis.x
	
	direction = forward * raw_input.y + right * raw_input.x
	
	return direction
