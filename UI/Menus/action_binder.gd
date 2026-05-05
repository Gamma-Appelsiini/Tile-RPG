extends HBoxContainer
class_name ActionBinder

signal keybind_set(new_keybind: InputEvent)

@export var action_name_label: Label = null
@export var bind_button: ReusableButton = null

var action: StringName
var keybind: InputEvent
var is_binding: bool = false

func _ready() -> void:
	set_process_input(false)
	bind_button.texture_button.pressed.connect(_bind_new_action)

func set_action(action_name: StringName) -> void:
	action = action_name
	action_name_label.text = action_name.capitalize()
	_update_bind_label()

func _bind_new_action() -> void:
	pass

func _update_bind_label() -> void:
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		keybind = events[0]
		bind_button.text_label.text = keybind.as_text().get_slice(" (", 0).replace(" - Physical", "")
	else:
		bind_button.text_label.text = "Unbound"
