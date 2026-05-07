extends PanelContainer
class_name RebindPanel

@export var movement_binds: VBoxContainer = null
@export var ability_binds: VBoxContainer = null
@export var general_binds: VBoxContainer = null
@export var camera_binds: VBoxContainer = null
@export var binding_info_panel: BindingInfoPanel = null
@export var reset_button: ReusableButton = null
@export var return_button: ReusableButton = null

const ACTION_BINDER: = preload("uid://c20ycfpjhiukv")
const MOVEMENT_ACTIONS:Array[String] = ["Forward", "Backward", "Left", "Right"]
const CAMERA_ACTIONS:Array[String] = ["Rotate Cam L", "Rotate Cam R", "Zoom In", "Zoom Out"]
const GENERAL_ACTIONS:Array[String] = ["Character", "Bag", "Abilities", "Journal","Highlight"]
const ACTIONS:Array[Array] = [MOVEMENT_ACTIONS, CAMERA_ACTIONS, GENERAL_ACTIONS]
const BINDS_FILE_PATH:String = "res://Tile-RPG/SaveData/bind_data.bin"

var binders:Array[ActionBinder] = []

func _ready() -> void:
	_add_inputs()
	reset_button.texture_button.pressed.connect(_reset_to_default_bindings)
	return_button.texture_button.pressed.connect(_save_keybinds)
	_load_keybinds()

func _reset_to_default_bindings() -> void:
	#Don't implement this yet
	pass

func _save_keybinds() -> void:
	hide()

	var binds_dict: Dictionary[StringName, InputEvent] = {}
	for binder:ActionBinder in binders:
		#print("Action: ", binder.action, " Keybind: ", binder.keybind)
		binds_dict[binder.action] = binder.keybind
	
	var file := FileAccess.open(BINDS_FILE_PATH, FileAccess.WRITE)
	# store_var with full_objects = true is required to save InputEvent objects
	if file: file.store_var(binds_dict, true)
	else: push_error("Failed to save keybinds. Error code: ", FileAccess.get_open_error())

func _load_keybinds() -> void:
	if not FileAccess.file_exists(BINDS_FILE_PATH):
		print_debug("No binds file")
		return
	
	var file := FileAccess.open(BINDS_FILE_PATH, FileAccess.READ)
	if !file:
		push_error("Failed to load keybinds. Error code: ", FileAccess.get_open_error())
		return
		
	var saved_binds:Dictionary = file.get_var(true)
	
	for binder:ActionBinder in binders:
		
		if saved_binds.has(binder.action):
			var saved_event: InputEvent = saved_binds[binder.action]
			#print("Action: ", binder.action, " Keybind: ", binder.keybind, " Saved Event: ", saved_event)
			binder.keybind = saved_event
			binder._update_bind_label()

			if InputMap.has_action(binder.action):
				InputMap.action_erase_events(binder.action)
				InputMap.action_add_event(binder.action, saved_event)

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
