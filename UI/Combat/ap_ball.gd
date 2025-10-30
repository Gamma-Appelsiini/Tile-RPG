extends PanelContainer
class_name ApBall

@export var ap_rect:TextureRect = null
var empty:bool = false

func show_ap() -> void:
	ap_rect.visible = true
	empty = false
	
func hide_ap() -> void:
	ap_rect.visible = false
	empty = true
