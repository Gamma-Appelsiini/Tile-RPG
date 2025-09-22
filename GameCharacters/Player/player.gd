extends GameCharacter
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 20
@export var player_camera:Camera3D
@export var visual_mesh:MeshInstance3D
@export var interact_handler:InteractHandler
@export var hp_globe: ResourceGlobe = null
@export var spirit_globe: ResourceGlobe = null

var came_from_id:String = "menu"
var _last_move_dir: Vector3 = Vector3.BACK
var movement_enabled:bool = true

func _ready() -> void:
	GlobalSignals.enable_player_movement.connect(_enable_movement)
	GlobalSignals.disable_player_movement.connect(_disable_movement)

func move_to_point(point: Vector3) -> void:
	movement_enabled = false
	await _move_to_point_internal(point)
	movement_enabled = true

func _move_to_point_internal(point: Vector3) -> void:
	var tolerance: float = 0.1
	while global_position.distance_to(point) > tolerance:
		var dir: Vector3 = (point - global_position).normalized()
		dir.y = 0.0
		velocity = dir * movement_speed
		move_and_slide()
		_turn_player(dir)
		await get_tree().physics_frame
	velocity = Vector3.ZERO

func rotate_towards_point(point: Vector3) -> void:
	movement_enabled = false
	await _rotate_to_point_internal(point)
	movement_enabled = true

func _rotate_to_point_internal(point: Vector3) -> void:
	var tolerance: float = 0.01
	while true:
		var dir: Vector3 = (point - global_position).normalized()
		dir.y = 0.0
		if dir.length() < 0.001:
			break
		
		var target_angle: float = Vector3.BACK.signed_angle_to(dir, Vector3.UP)
		var current_angle: float = visual_mesh.global_rotation.y
		var new_angle: float = lerp_angle(current_angle, target_angle, 0.2)
		visual_mesh.global_rotation.y = new_angle
		
		if absf(current_angle - target_angle) < tolerance:
			break
		
		await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * movement_speed, acceleration * delta)
	move_and_slide()
	_turn_player(move_direction)

func _enable_movement() -> void:
	movement_enabled = true
	
func _disable_movement() -> void:
	movement_enabled = false

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
