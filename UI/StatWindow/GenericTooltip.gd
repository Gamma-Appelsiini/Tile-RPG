extends VBoxContainer
class_name MainStatTooltip

@export var stat_name: Label = null
@export var stat_desc: Label = null
@export var stat_flavor: Label = null

func show_tooltip() -> void:
	self.visible = true
	
	var control_parent:Control = get_parent()
	var offset:Vector2 = Vector2(-self.size.x / 2 + control_parent.size.x / 2, -self.size.y - 2)
	
	self.global_position = control_parent.global_position + offset
