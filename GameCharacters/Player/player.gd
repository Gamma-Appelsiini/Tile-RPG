extends CharacterBody3D
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 20
@export var player_camera:Camera3D

@export var visual_mesh:MeshInstance3D
var _last_move_dir: Vector3 = Vector3.BACK

func _physics_process(delta: float) -> void:
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := player_camera.global_basis.z
	var right := player_camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * movement_speed, acceleration * delta)
	move_and_slide()
	_turn_player(move_direction)
	

func _turn_player(move_direction:Vector3):
	if move_direction.length() > 0.2:
		_last_move_dir = move_direction
		
	var target_angle: float = Vector3.BACK.signed_angle_to(_last_move_dir, Vector3.UP)
	visual_mesh.global_rotation.y = target_angle
