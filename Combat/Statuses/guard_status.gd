extends Status
class_name GuardStatus

const GUARD_SHIELDS := preload("uid://chgwg7xl3kvpd")

var shield_effect:Effect = null

#Overrided
func _connet_to_char_signals() -> void:
	affected_gchar.got_hit.connect(_on_hit)

func _on_hit() -> void:
	GlobalSignals.show_floating_text.emit("Guarded", affected_gchar.heigth_node, Color(0.788, 0.686, 0.014, 1.0))
	affected_gchar.status_handler._remove_status(self)

#Overrided
func on_status_added() -> void:
	shield_effect = GUARD_SHIELDS.instantiate()
	affected_gchar.add_child(shield_effect)
	shield_effect.position.y += affected_gchar.heigth_node.position.y / 2

#Overrided
func on_status_removed() -> void:
	remove_status.emit()
	shield_effect.end_effect()
	queue_free()
