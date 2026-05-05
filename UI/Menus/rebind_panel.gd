extends PanelContainer
class_name RebindPanel

@export var movement_binds: VBoxContainer = null
@export var ability_binds: VBoxContainer = null
@export var general_binds: VBoxContainer = null
@export var camera_binds: VBoxContainer = null

const ACTION_BINDER: = preload("uid://c20ycfpjhiukv")
const MOVEMENT_ACTIONS:Array[StringName] = ["Forward", "Backward", "Left", "Right"]
const CAMERA_ACTIONS:Array[StringName] = ["Rotate_Cam_L", "Rotate_Cam_R", "Zoom_In", "Zoom_Out"]
const GENERAL_ACTIONS:Array[StringName] = ["Character", "Bag", "Abilities", "Journal","Highlight"]
const ACTIONS:Array[Array] = [MOVEMENT_ACTIONS, CAMERA_ACTIONS, GENERAL_ACTIONS]

func _ready() -> void:
	_add_inputs()

func _add_inputs() -> void:
	var number:int = 0
	while number < 10:
		var new_binder:ActionBinder = ACTION_BINDER.instantiate()
		ability_binds.add_child(new_binder)
		new_binder.set_action("ability " + str(number))
		number += 1
	
	for array in ACTIONS:

		for event:StringName in array:
			var new_binder:ActionBinder = ACTION_BINDER.instantiate()
			new_binder.set_action(event)
			
			if MOVEMENT_ACTIONS.has(event): movement_binds.add_child(new_binder)
			elif CAMERA_ACTIONS.has(event): camera_binds.add_child(new_binder)
			elif GENERAL_ACTIONS.has(event): general_binds.add_child(new_binder)
