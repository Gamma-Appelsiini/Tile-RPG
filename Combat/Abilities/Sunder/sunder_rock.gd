extends Node3D
class_name SunderRock

@export var rock_sound:AudioStream = null
@export var rocks: Node3D = null
@export var fragments: Node = null
@export var smoke: GPUParticles3D = null
@export var dirt: GPUParticles3D = null
@export var decal: Decal = null

const EXPLOSION_SPEED:float = 8.0

func spawn_rock() -> void:
	_animate_decal()
	rotation.y = deg_to_rad(randi_range(0, 360))
	
	GlobalSignals.play_audio.emit(rock_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, global_position)
	smoke.emitting = true
	dirt.emitting = true
	_shoot_rocks()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(rocks,"position", Vector3(0,0,0), 0.3)
	await get_tree().create_timer(0.5).timeout
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(rocks,"position", Vector3(0,-0.65,0), 0.9)
	
	await get_tree().create_timer(3).timeout
	queue_free()

func _animate_decal() -> void:
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(decal,"albedo_mix", 1.0, 0.1)
	tween.tween_property(decal,"modulate", Color("000000"), 0.4)
	
	await get_tree().create_timer(1).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(decal,"modulate:a", 0, 2)

func _shoot_rocks() -> void:
	var last_frag:Fragment = fragments.get_children().back()
	last_frag.dissolved.connect(queue_free)

	for frag:Fragment in fragments.get_children():
		var fragment_speed:float = randf_range(EXPLOSION_SPEED-2,EXPLOSION_SPEED+2)
		var vel:Vector3 = (frag.global_transform.origin - global_position ) * fragment_speed
		frag.explode(vel)
