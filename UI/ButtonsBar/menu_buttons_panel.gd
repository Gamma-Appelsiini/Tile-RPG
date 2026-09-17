extends Control
class_name MenuButtonsPanel

signal open_abi
signal open_inv
signal open_char
signal open_journal
signal open_party
signal open_settings
signal open_skill_tree

@export var h_box_container: HBoxContainer = null
@export var button_name_tool_tip: ButtonNameTooltip = null

var signals:Array[Callable] = [open_abi.emit, open_inv.emit, open_char.emit, open_journal.emit, open_skill_tree.emit, open_party.emit, open_settings.emit]
var buttons:Array[Button] = []

func _ready() -> void:
	_connect_buttons()

func _connect_buttons() -> void:
	for child:Control in h_box_container.get_children():
		if child is GenericButton: 
			buttons.push_back(child.button)
			child.button.mouse_entered.connect(_show_name_tooltip.bind(child))
			child.button.mouse_exited.connect(button_name_tool_tip.hide)
	
	for i:int in len(buttons):
		buttons[i].pressed.connect(signals[i])

func _show_name_tooltip(button:Control) -> void:
	button_name_tool_tip.show_tooltip(button.name, button)
