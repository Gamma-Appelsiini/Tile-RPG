extends Status
class_name Freeze

const FREEZE_EFFECT := preload("uid://bfynceomv32xx")

var freeze_effect:Effect = null
var in_combat:bool = true

#Overrided
func on_status_added() -> void:
	freeze_effect = FREEZE_EFFECT.instantiate()

	affected_gchar.add_child(freeze_effect)
	freeze_effect.global_position = affected_gchar.global_position

	affected_gchar.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.FROZEN, false)
	affected_gchar.change_state(GameCharacter.CharacterState.FROZEN)
	
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	
#Overrided
func on_status_removed() -> void:
	freeze_effect.end_effect()
	
	if in_combat:
		affected_gchar.change_state(GameCharacter.CharacterState.IN_COMBAT)
	else:
		affected_gchar.change_state(GameCharacter.CharacterState.OUT_OF_COMBAT)
		
	queue_free()
