extends Node3D
class_name TacticalCamera

@export var camera_3d: Camera3D = null
@export var move_node: Node3D = null
@export var audio_listener_3d: AudioListener3D = null

const MAX_DISTANCE:float = 20
const CAMERA_SPEED:float = 3

var rotating:bool = false

func _init() -> void:
	set_physics_process(false)
	set_process_input(false)

func _physics_process(delta: float) -> void:
	var move_direction := _handle_movement_input()
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	if move_direction != Vector3.ZERO:
		var new_pos := self.global_position + move_direction * CAMERA_SPEED * delta
		var offset := new_pos - self.global_position
		var dist := offset.length()

		if dist > MAX_DISTANCE:
			offset = offset.normalized() * MAX_DISTANCE
			new_pos = self.global_position + offset

		self.global_position = new_pos

func set_active() -> void:
	set_physics_process(true)
	set_process_input(true)
	
func set_inactive() -> void:
	set_process_input(false)
	camera_3d.position = Vector3.ZERO
	
func _rotate_cam(amount:float) -> void:
	if rotating: return
	rotating = true
	
	var rotation_time:float = 0.25
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera_3d,"rotation:y",camera_3d.rotation.y + deg_to_rad(amount), rotation_time)
	
	await tween.finished
	rotating = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Cam L"):
		_rotate_cam(-90)
	elif event.is_action_pressed("Rotate Cam R"):
		_rotate_cam(90)
	elif event.is_action_pressed("Zoom In"):
		_zoom_cam(-1)
	elif event.is_action_pressed("Zoom Out"):
		_zoom_cam(1)
		
func _zoom_cam(dir:float) -> void:
	const MAX_ZOOM_IN:float = 3.0
	const MAX_ZOOM_OUT:float = 20
	const MOVE_AMOUNT: float = 0.5
	var final_pos:float = clamp(camera_3d.position.y + MOVE_AMOUNT * dir, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(move_node, "position:y", final_pos, 0.1)
	
	
func _handle_movement_input() -> Vector3:
	var direction:Vector3 = Vector3.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Backward")
	var forward := self.global_basis.z
	var right := self.global_basis.x
	
	direction = forward * raw_input.y + right * raw_input.x
	
	return direction
