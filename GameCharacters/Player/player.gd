extends GameCharacter
class_name Player

@export var movement_speed:float = 8
@export var acceleration:float = 14
@export var interact_handler:InteractHandler
@export var hp_globe: ResourceGlobe = null
@export var spirit_globe: ResourceGlobe = null
@export var camera_handler: CameraHandler = null

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var came_from_id:String = "menu"
var _last_move_dir: Vector3 = Vector3.BACK
var movement_enabled:bool = true
var movement_disablers:int = 0
var player_camera:Camera3D = null

func _ready() -> void:
	_connect_signals()
	player_camera = camera_handler.player_camera.camera_3d

func _connect_signals() -> void:
	GlobalSignals.enable_player_movement.connect(enable_movement)
	GlobalSignals.disable_player_movement.connect(disable_movement)

#Overrided
func enter_interact_state(interact_animation:CharacterModelHandler.CharAnimation) -> void:
	disable_movement()
	set_process_input(false)
	
	char_model_handler.play_animation(interact_animation, false)
	await char_model_handler.animation_player.animation_finished
	
	enable_movement()
	set_process_input(true)
	change_state(CharacterState.OUT_OF_COMBAT)

#Overrided
func _enter_out_of_combat_state(prev_state:CharacterState) -> void:
	if prev_state == CharacterState.IN_COMBAT:
		char_model_handler.play_animation(CharacterModelHandler.CharAnimation.DRAW_WEAPON,true, true)
		await get_tree().create_timer(char_model_handler.DELAYS[CharacterModelHandler.CharAnimation.DRAW_WEAPON]).timeout
		hide_weapon.emit()
		await char_model_handler.animation_player.animation_finished
		enable_movement()
	else:
		char_model_handler.play_idle_animation()

#Overrided
func _enter_combat_state(prev_state:CharacterState) -> void:
	disable_movement()
	if prev_state != CharacterState.IN_COMBAT:
		char_model_handler.play_animation(CharacterModelHandler.CharAnimation.DRAW_WEAPON, false)
		await get_tree().create_timer(char_model_handler.DELAYS[CharacterModelHandler.CharAnimation.DRAW_WEAPON]).timeout
		draw_weapon.emit()
		await char_model_handler.animation_player.animation_finished
		ready_to_move.emit()
	else:
		char_model_handler.play_idle_animation()

#Overrided
func _enter_dead_state() -> void:
	GlobalSignals.combat_start.disconnect(change_state.bind(CharacterState.IN_COMBAT))
	GlobalSignals.combat_end.disconnect(change_state.bind(CharacterState.OUT_OF_COMBAT))
	
	char_model_handler.die()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Highlight"):
		GlobalSignals.show_outline.emit()
		GlobalSignals.show_info_bar.emit()
	elif event.is_action_released("Highlight"):
		GlobalSignals.hide_outline.emit()
		GlobalSignals.hide_info_bar.emit()

func enable_movement() -> void:
	movement_disablers -= 1

	if movement_disablers <= 0:
		set_physics_process(true)
		movement_enabled = true
	
func disable_movement() -> void:
	movement_disablers += 1

	set_physics_process(false)
	movement_enabled = false

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

func rotate_towards_point(point: Vector3) -> void:
	set_process(false)
	
	var tween:Tween = _rotate(point)
	await tween.finished
	
	rotation_complete.emit()
	_last_move_dir = Vector3.BACK.rotated(Vector3.UP, char_model_handler.global_rotation.y)
	
	set_process(true)
