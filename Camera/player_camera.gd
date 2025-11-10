extends Camera3D
class_name PlayerCamera

@export var pivot:Node3D

var rotating:bool = false
var zoom_enabled:bool = true
const ZOOM_DEFAULT:float = 11
const RESET_TIME:float = 0.75
var old_zoom:float = 0

func _ready() -> void:
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate_Cam_L"):
		_rotate_cam(-90)
	elif event.is_action_pressed("Rotate_Cam_R"):
		_rotate_cam(90)
	elif event.is_action_pressed("roll_up"):
		_zoom_cam(-1)
	elif event.is_action_pressed("roll_down"):
		_zoom_cam(1)

func _on_combat_start() -> void:
	set_process_input(false)

func _on_combat_end() -> void:
	set_process_input(true)

func _rotate_cam(amount:float) -> void:
	if rotating: return
	rotating = true
	
	var rotation_time:float = 0.25
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pivot,"rotation:y",pivot.rotation.y + deg_to_rad(amount), rotation_time)
	
	await tween.finished
	rotating = false

func _zoom_cam(dir:float) -> void:
	if !zoom_enabled: return
	const MAX_ZOOM_IN:float = 4.0
	const MAX_ZOOM_OUT:float = 10
	
	var move_amount: float = 0.5
	self.size = clamp(self.size + move_amount * dir, MAX_ZOOM_IN, MAX_ZOOM_OUT)

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
