extends Node3D
class_name SunderRock

@export var rock_sound:AudioStream = null
@export var rocks: Node3D = null
@export var fragments: Node = null
@export var smoke: GPUParticles3D = null

const EXPLOSION_SPEED:float = 5.0

func spawn_rock() -> void:
	GlobalSignals.play_audio.emit(rock_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, global_position)
	smoke.emitting = true
	_shoot_rocks()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(rocks,"position", Vector3(0,0,0), 0.3)
	await get_tree().create_timer(0.5).timeout
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(rocks,"position", Vector3(0,-0.65,0), 0.5)
	
	await get_tree().create_timer(2.3).timeout
	queue_free()

func _shoot_rocks() -> void:
	var last_frag:Fragment = fragments.get_children().back()
	last_frag.dissolved.connect(queue_free)
	
	for frag:Fragment in fragments.get_children():
		var fragment_speed:float = randf_range(EXPLOSION_SPEED-1,EXPLOSION_SPEED+1)
		var vel:Vector3 = (frag.global_transform.origin - global_position) * fragment_speed
		frag.explode(vel)
