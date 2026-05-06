extends PanelContainer
class_name RebindPanel

@export var movement_binds: VBoxContainer = null
@export var ability_binds: VBoxContainer = null
@export var general_binds: VBoxContainer = null
@export var camera_binds: VBoxContainer = null
@export var binding_info_panel: BindingInfoPanel = null

const ACTION_BINDER: = preload("uid://c20ycfpjhiukv")
const MOVEMENT_ACTIONS:Array[String] = ["Forward", "Backward", "Left", "Right"]
const CAMERA_ACTIONS:Array[String] = ["Rotate Cam L", "Rotate Cam R", "Zoom In", "Zoom Out"]
const GENERAL_ACTIONS:Array[String] = ["Character", "Bag", "Abilities", "Journal","Highlight"]
const ACTIONS:Array[Array] = [MOVEMENT_ACTIONS, CAMERA_ACTIONS, GENERAL_ACTIONS]

var binders:Array[ActionBinder] = []

func _ready() -> void:
	_add_inputs()

func _show_binding_info(binder:ActionBinder) -> void:
	binding_info_panel.show_panel(binder.action)
	binding_info_panel.cancel_button.texture_button.pressed.connect(binder._stop_binding, CONNECT_ONE_SHOT)
	binder.stop_binding.connect(binding_info_panel.hide, CONNECT_ONE_SHOT)

func _unbind_overlap(rebound_binder:ActionBinder):
	for binder:ActionBinder in binders:
		if binder == rebound_binder: continue
		if binder.keybind and rebound_binder.keybind and binder.keybind.is_match(rebound_binder.keybind):
			binder.unbind_action()

func _add_inputs() -> void:
	var number:int = 0
	while number < 10:
		var new_binder:ActionBinder = ACTION_BINDER.instantiate()
		ability_binds.add_child(new_binder)
		
		new_binder.start_binding.connect(_show_binding_info)
		new_binder.keybind_set.connect(_unbind_overlap)
		
		new_binder.set_action("ability " + str(number))
		binders.push_back(new_binder)
		
		number += 1
	
	for array in ACTIONS:

		for event:String in array:
			var new_binder:ActionBinder = ACTION_BINDER.instantiate()
			new_binder.start_binding.connect(_show_binding_info)
			new_binder.keybind_set.connect(_unbind_overlap)
			
			if MOVEMENT_ACTIONS.has(event): movement_binds.add_child(new_binder)
			elif CAMERA_ACTIONS.has(event): camera_binds.add_child(new_binder)
			elif GENERAL_ACTIONS.has(event): general_binds.add_child(new_binder)
			
			new_binder.set_action(event)
			binders.push_back(new_binder)
