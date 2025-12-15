extends Control
class_name StatusTooltip

@export var status_name: Label = null
@export var status_desc: Label = null
@export var duration: Label = null


func set_status(new_status:Status) -> void:
	new_status.duration_changed.connect(_update_status.bind(new_status))
	_update_status(new_status)


func _update_status(status:Status) -> void:
	status_name.text = status.status_name
	status_desc.text = status.description
	duration.text = str(status.current_duration)

func _show_tt() -> void:
	self.visible = true
	self.global_position = get_parent_control().global_position + Vector2(0,self.size.y)
