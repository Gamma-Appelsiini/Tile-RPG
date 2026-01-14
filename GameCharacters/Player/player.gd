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
	_connect_signals()
	_set_infobar()

func _connect_signals() -> void:
	GlobalSignals.combat_start.connect(_disable_movement)
	GlobalSignals.combat_end.connect(_enable_movement)
	GlobalSignals.enable_player_movement.connect(_enable_movement)
	GlobalSignals.disable_player_movement.connect(_disable_movement)
	GlobalSignals.combat_start.connect(change_state.bind(CharacterState.IN_COMBAT))
	GlobalSignals.combat_end.connect(change_state.bind(CharacterState.OUT_OF_COMBAT))

#Overrided
func _enter_dead_state() -> void:
	GlobalSignals.combat_start.disconnect(change_state.bind(CharacterState.IN_COMBAT))
	GlobalSignals.combat_end.disconnect(change_state.bind(CharacterState.OUT_OF_COMBAT))
	GlobalSignals.combat_start.disconnect(_disable_movement)
	GlobalSignals.combat_end.disconnect(_enable_movement)
	
	char_model_handler.die()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Highlight"):
		GlobalSignals.show_outline.emit()
		GlobalSignals.show_info_bar.emit()
	elif event.is_action_released("Highlight"):
		GlobalSignals.hide_outline.emit()
		GlobalSignals.hide_info_bar.emit()

func _physics_process(delta: float) -> void:
	if velocity != Vector3.ZERO and character_state != CharacterState.RUNNING:
		change_state(CharacterState.RUNNING)
	elif velocity == Vector3.ZERO and character_state == CharacterState.RUNNING:
		change_state(CharacterState.OUT_OF_COMBAT)

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * movement_speed, acceleration * delta)
	move_and_slide()
	_turn_player(move_direction)

func _enable_movement() -> void:
	set_physics_process(true)
	movement_enabled = true
	
func _disable_movement() -> void:
	set_physics_process(false)
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
	char_model_handler.global_rotation.y = target_angle
