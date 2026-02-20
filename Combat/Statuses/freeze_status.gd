extends Status
class_name Freeze

@export var freeze_sound:AudioStream = null

const FREEZE_EFFECT := preload("uid://bfynceomv32xx")

var freeze_effect:Effect = null
var in_combat:bool = true

#Overrided
func on_status_added() -> void:
	freeze_effect = FREEZE_EFFECT.instantiate()
	GlobalSignals.play_audio.emit(freeze_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, affected_gchar.global_position)

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
		
	await freeze_effect.animation_player.animation_finished
	queue_free()

#Overrided
func _on_start_turn() -> void:
	current_duration -= 1
	duration_changed.emit()
	if current_duration <= 0: remove_status.emit()
	else:
		GlobalSignals.show_floating_text.emit("Frozen", affected_gchar,status_color)
