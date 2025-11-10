extends GameCharacter
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 14
@export var player_camera:Camera3D
@export var interact_handler:InteractHandler
@export var hp_globe: ResourceGlobe = null
@export var spirit_globe: ResourceGlobe = null

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var came_from_id:String = "menu"
var _last_move_dir: Vector3 = Vector3.BACK
var movement_enabled:bool = true

func _ready() -> void:
	GlobalSignals.combat_start.connect(_disable_movement)
	GlobalSignals.combat_end.connect(_enable_movement)
	GlobalSignals.enable_player_movement.connect(_enable_movement)
	GlobalSignals.disable_player_movement.connect(_disable_movement)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Highlight"):
		GlobalSignals.show_outline.emit()
	elif event.is_action_released("Highlight"):
		GlobalSignals.hide_outline.emit()

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
func _rotate(point: Vector3) -> Tween:
	var dir: Vector3 = (point - global_position).normalized()
	var target_yaw: float = atan2(dir.x, dir.z)
	var current_yaw: float = visual_mesh.rotation.y

	var delta: float = wrapf(target_yaw - current_yaw, -PI, PI)
	var final_yaw: float = current_yaw + delta

	const FULL_ROTATION_TIME: float = 0.8
	var angle_diff: float = abs(delta)
	var rotation_time: float = clampf(FULL_ROTATION_TIME * (angle_diff / PI), 0.1, FULL_ROTATION_TIME)
	
	var tween := create_tween()
	tween.tween_property(visual_mesh, "rotation:y", final_yaw, rotation_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_last_move_dir = dir
	
	return tween
