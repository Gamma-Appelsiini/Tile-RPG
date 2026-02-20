extends Node3D
class_name Projectile

signal hit_target

@export var projectile_speed:float = 2.0
@export var meshes_to_show_on_shoot:Array[Node3D] = []
@export var hit_sound:AudioStream = null

const time_per_meter:float = 1

func shoot_at_pos(pos:Vector3) -> void:
	_show_meshes()
	
	self.top_level = true
	self.look_at(pos)
	var travel_time:float = self.global_position.distance_to(pos) * time_per_meter / projectile_speed
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", pos, travel_time)
	
	await tween.finished
	hit_target.emit()
	_on_hit()

func _show_meshes() -> void:
	for node:Node3D in meshes_to_show_on_shoot:
		node.show()

#Override this
func _on_hit() -> void:
	GlobalSignals.play_audio.emit(hit_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	
	for child:Node3D in get_children():
		if child is GPUParticles3D:
			child.emitting = false
			continue
		child.hide()
		
	await get_tree().create_timer(2).timeout
	
	queue_free()
