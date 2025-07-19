extends Camera3D

@export var pivot:Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Rotate_Cam_L"):
		pivot.rotate_y(deg_to_rad(-90))
	elif event.is_action_pressed("Rotate_Cam_R"):
		pivot.rotate_y(deg_to_rad(90))
