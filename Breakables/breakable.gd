extends Node3D
class_name Breakable

signal broken

@export var explosion_speed:float = 6
@export var static_body:StaticBody3D
@export var break_sound: AudioStream = null
@export var original_model:Node3D = null
@export var fragments_node:Node3D = null
@export var block_tiles:bool = false
@export var particle_emitters:Array[GPUParticles3D] = []
@export var interactable:Interactable = null

const WAIT_TIMES:Dictionary[CharacterModelHandler.CharAnimation, float] = {
	CharacterModelHandler.CharAnimation.ATTACK_PUNCH: 0.4,
	
}

var explode_origin:Vector3 = Vector3.ZERO

func on_interaction(body: Player) -> void:
	if WAIT_TIMES.has(interactable.interact_animation):
		await get_tree().create_timer(WAIT_TIMES[interactable.interact_animation]).timeout
	
	explode_origin = body.global_position
	_explode()

func _explode() -> void:
	broken.emit()
	if original_model: original_model.visible = false
	static_body.queue_free()
	
	for emitter:GPUParticles3D in particle_emitters:
		emitter.emitting = true
	
	var last_frag:Fragment = fragments_node.get_children().back()
	last_frag.dissolved.connect(queue_free)
	GlobalSignals.play_audio.emit(break_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, explode_origin)
	
	for frag:Fragment in fragments_node.get_children():
		var fragment_speed:float = randf_range(explosion_speed-1,explosion_speed+1)
		var vel:Vector3 = (frag.global_transform.origin - explode_origin) * fragment_speed
		frag.explode(vel)
