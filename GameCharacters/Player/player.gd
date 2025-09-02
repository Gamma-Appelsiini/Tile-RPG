extends GameCharacter
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 20
@export var player_camera:Camera3D
@export var visual_mesh:MeshInstance3D
@export var interact_handler:InteractHandler

var came_from_id:String = "menu"
var _last_move_dir: Vector3 = Vector3.BACK
var movement_enabled:bool = true

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * movement_speed, acceleration * delta)
	move_and_slide()
	_turn_player(move_direction)

func _input(_event: InputEvent) -> void:
	pass

func _handle_movement_input() -> Vector3:
	var direction:Vector3 = Vector3.ZERO
	if !movement_enabled: return direction
	
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := player_camera.global_basis.z
	var right := player_camera.global_basis.x
	
	direction = forward * raw_input.y + right * raw_input.x
	
	return direction

func _turn_player(move_direction:Vector3) -> void:
	if move_direction.length() > 0.2:
		_last_move_dir = move_direction
		
	var target_angle: float = Vector3.BACK.signed_angle_to(_last_move_dir, Vector3.UP)
	visual_mesh.global_rotation.y = target_angle
