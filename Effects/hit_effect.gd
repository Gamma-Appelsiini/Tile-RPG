extends Effect
class_name HitEffect

@export var duration:float = 0
@export var hit_texture:Texture2D = null
@export var gradient:GradientTexture1D = null
@export var hit_sounds:Array[AudioStream] = []

@export var gpu_particles_3d: GPUParticles3D = null

func _ready() -> void:
	_handle_hit_modifications()
	_handle_start()
	
func _handle_hit_modifications() -> void:
	if duration > 0: gpu_particles_3d.lifetime = duration
	
	if hit_texture:
		var shader_material:ShaderMaterial = gpu_particles_3d.material_override as ShaderMaterial
		shader_material.set_shader_parameter("hit_texture", hit_texture)
	
	if gradient: gpu_particles_3d.process_material.set("color_ramp",gradient)

#Overrided
func play_effect() -> void:
	show() 
	_play_effect_sound()
	gpu_particles_3d.emitting = true
	await get_tree().create_timer(gpu_particles_3d.lifetime).timeout
	queue_free()

#Overrided
func _play_effect_sound() -> void:
	if hit_sounds.is_empty(): GlobalSignals.play_audio.emit(effect_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	else: GlobalSignals.play_audio.emit(hit_sounds.pick_random(), AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
