extends Control
class_name UIHandler

@export var character_window:StatWindow = null
var input_enabled:bool = true

func _input(event: InputEvent) -> void:
	if !input_enabled: return
	if event.is_action_pressed("Character"):
		character_window.visible = !character_window.visible
