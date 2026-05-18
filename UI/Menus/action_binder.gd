extends HBoxContainer
class_name ActionBinder

signal keybind_set(binder:ActionBinder)
signal stop_binding
signal start_binding(binder:ActionBinder)

@export var action_name_label: Label = null
@export var bind_button: ReusableButton = null

const UNBINDABLE_INPUTS:Array[StringName] = ["Left Click", "Right Click"]

var action: StringName
var keybind: InputEvent

func unbind_action() -> void:
	InputMap.action_erase_events(action)
	update_bind_label()

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if not (event is InputEventKey or event is InputEventMouseButton):
		return
	
	if event.is_action("Esc"):
		_stop_binding()
		return
	for action_name:StringName in UNBINDABLE_INPUTS:
		if event.is_action(action_name): return
	
	_bind_new_action(event)
	
func _ready() -> void:
	set_process_input(false)
	bind_button.texture_button.pressed.connect(_start_binding)

func set_action(action_name: StringName) -> void:
	action = action_name
	action_name_label.text = action_name.capitalize()
	update_bind_label()

func _bind_new_action(event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	keybind = event
	print("Rebinded ", action, " to ", event)
	
	update_bind_label()
	keybind_set.emit(self)
	_stop_binding()

func _start_binding() -> void:
	set_process_input(true)
	start_binding.emit(self)

func _stop_binding() -> void:
	set_process_input(false)
	stop_binding.emit()

func update_bind_label() -> void:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		keybind = events[0]
		bind_button.text_label.text = keybind.as_text().get_slice(" (", 0).replace(" - Physical", "")
	else:
		keybind = null
		bind_button.text_label.text = "Unbound"
