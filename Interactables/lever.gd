extends Interactable
class_name Lever

@export var node_to_call:Node3D = null
@export var rotation_node: Node3D = null
@export var rotation_time:float = 0.45

var lever_rotation:float = 45
var interaction_enabled:bool = true

#Overrided
func interact() -> void:
	if !interaction_enabled: return
	interaction_enabled = false
	interact_area.monitoring = false
	
	await _rotate_lever()
	
	if node_to_call != null:
		if node_to_call.has_method("on_lever_use"): node_to_call.on_lever_use()
	
	interaction_enabled = true
	interact_area.monitoring = true
	
	handle_oneshot()

func _rotate_lever() -> void:
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(rotation_node, "rotation:x", deg_to_rad(lever_rotation), rotation_time)
	await tween.finished
	
	lever_rotation *= -1
