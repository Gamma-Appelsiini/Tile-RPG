extends VBoxContainer
class_name ButtonNameTooltip

@export var ui_desc: Label
@export var cost_container: HBoxContainer
@export var cost_label: Label

func _ready() -> void:
	hidden.connect(cost_container.hide)

func show_tooltip(text:String, ui_node:Control) -> void:
	ui_desc.text = text
	var offset:Vector2 = Vector2(-self.size.x / 2 + ui_node.size.x / 2, -self.size.y + 5)
	self.global_position = ui_node.global_position + offset
	show()
