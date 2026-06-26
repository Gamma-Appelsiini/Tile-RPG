extends Node3D
class_name PlayerCamera

@export var pivot:Node3D = null
@export var camera_3d: Camera3D = null
@export var audio_listener_3d: AudioListener3D = null

var rotating:bool = false
var zoom_enabled:bool = true
const ZOOM_DEFAULT:float = 11
const RESET_TIME:float = 0.75
var old_zoom:float = 0

var default_pos:Vector3
var target_position: Vector3 = Vector3.ZERO
var zoom_tween: Tween = null

func set_as_active_camera() -> void:
	print("SET AS ACTIVE: ", name)
	set_process_input(true)
	set_physics_process(true)
	GlobalSignals.player.player_camera = camera_3d
	audio_listener_3d.make_current()
	
func disactivate_camera() -> void:
	set_process_input(false)
	set_physics_process(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate Cam L"):
		_rotate_cam(-45)
	elif event.is_action_pressed("Rotate Cam R"):
		_rotate_cam(45)
	elif event.is_action_pressed("Zoom In"):
		_move_camera(true)
	elif event.is_action_pressed("Zoom Out"):
		_move_camera(false)

func _rotate_cam(amount:float) -> void:
	if rotating: return
	rotating = true
	
	var rotation_time:float = 0.25
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pivot,"rotation:y",pivot.rotation.y + deg_to_rad(amount), rotation_time)
	
	await tween.finished
	rotating = false

func _move_camera(towards: bool) -> void:
	if !zoom_enabled: return
	
	const MOVE_AMOUNT: float = 0.5
	const ZOOM_DURATION: float = 0.25
	const MAX_IN_AMOUNT:float = 4.0
	const MAX_OUT_AMOUNT:float = 30.0

	if !zoom_tween or !zoom_tween.is_valid():
		target_position = camera_3d.position

	var direction: Vector3 = -camera_3d.transform.basis.z if towards else camera_3d.transform.basis.z
	var new_target:Vector3 = target_position + (direction * MOVE_AMOUNT)
	if Vector3.ZERO.distance_to(new_target) > MAX_OUT_AMOUNT or Vector3.ZERO.distance_to(new_target) < MAX_IN_AMOUNT:
		return
	
	target_position += direction * MOVE_AMOUNT

	if zoom_tween and zoom_tween.is_valid():
		zoom_tween.kill()

	zoom_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(camera_3d, "position", target_position, ZOOM_DURATION)

func disable_zooming() -> void:
	zoom_enabled = false
	old_zoom = self.size
	
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"size",ZOOM_DEFAULT, RESET_TIME)
	
func enable_zooming() -> void:
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"size",old_zoom, RESET_TIME)
	
	await tween.finished
	zoom_enabled = true
