extends Status
class_name Stunned

const STUNNED_EFFECT := preload("uid://dbutbh1koaptg")

var stun_effect:Effect = null
var in_combat:bool = true

#Overrided
func on_status_added() -> void:
	stun_effect = STUNNED_EFFECT.instantiate()

	affected_gchar.char_model_handler.head_node.add_child(stun_effect)
	stun_effect.global_position = affected_gchar.char_model_handler.head_node.global_position

	affected_gchar.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.STUNNED, false)
	affected_gchar.change_state(GameCharacter.CharacterState.FROZEN)
	
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	
#Overrided
func on_status_removed() -> void:
	stun_effect.end_effect()
	
	if in_combat:
		affected_gchar.change_state(GameCharacter.CharacterState.IN_COMBAT)

	queue_free()

#Overrided
func _on_start_turn() -> void:
	current_duration -= 1
	duration_changed.emit()
	if current_duration <= 0: remove_status.emit()
	else:
		GlobalSignals.show_floating_text.emit("Stunned", affected_gchar,status_color)
