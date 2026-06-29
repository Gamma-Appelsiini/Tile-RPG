extends Node3D
class_name CamOverrideArea

@export var override_camera:Node3D = null
@onready var interact_area: Area3D = $InteractArea

func _ready() -> void:
	interact_area.body_entered.connect(_area_entered)
	
func _area_entered(enterer:Node3D) -> void:
	if enterer is not Player: return
	print(enterer)

	interact_area.set_deferred("monitoring", false)
	if !override_camera:
		GlobalSignals.change_off_override_cam.emit()
		return
	
	for child:Node in override_camera.get_children():
		if child is Camera3D: GlobalSignals.change_to_override_cam.emit(child as Camera3D)
