extends GameCharacter
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 20
@export var player_camera:Camera3D
@export var interact_handler:InteractHandler
@export var hp_globe: ResourceGlobe = null
@export var spirit_globe: ResourceGlobe = null

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var came_from_id:String = "menu"
var _last_move_dir: Vector3 = Vector3.BACK
var movement_enabled:bool = true

func _ready() -> void:
	GlobalSignals.enable_player_movement.connect(_enable_movement)
	GlobalSignals.disable_player_movement.connect(_disable_movement)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
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

#Overrided
func rotate_towards_point(point: Vector3) -> void:
	set_physics_process(false)
	
	const ROTATION_TIME: float = 0.4
	var dir: Vector3 = (point - global_position).normalized()
	var target_yaw: float = atan2(dir.x, dir.z)
	var current_yaw: float = visual_mesh.rotation.y
	var delta: float = fmod((target_yaw - current_yaw) + PI, TAU) - PI
	var final_yaw: float = current_yaw + delta
	
	_last_move_dir = dir

	var tween := create_tween()
	tween.tween_property(visual_mesh, "rotation:y", final_yaw, ROTATION_TIME).set_trans(TRANS_TYPE).set_ease(EASE_TYPE)

	await tween.finished
	rotation_complete.emit()
	set_physics_process(true)
