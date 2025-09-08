extends Control
class_name UIHandler

@export var character_window:StatWindow = null
@onready var inventory: Inventory = %Inventory
@onready var globe_ui: GlobeUI = %GlobeUI

var input_enabled:bool = true

func _input(event: InputEvent) -> void:
	if !input_enabled: return
	if event.is_action_pressed("Character"):
		character_window.visible = !character_window.visible
	elif event.is_action_pressed("Bag"):
		inventory.visible = !inventory.visible
