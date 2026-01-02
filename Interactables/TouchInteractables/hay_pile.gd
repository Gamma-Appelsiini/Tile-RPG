extends TouchInteractable
class_name HayPile

@export var hay_rustle_sound:AudioStream = null
@export var cpu_particles_3d: CPUParticles3D = null

#Overrided
func _on_interaction() -> void:
	GlobalSignals.play_audio.emit(hay_rustle_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	cpu_particles_3d.emitting = true
