extends Node3D
class_name Projectile

signal hit_target

@export var projectile_speed:float = 2.0

const time_per_meter:float = 1

func shoot_at_pos(pos:Vector3) -> void:
	self.top_level = true
	self.look_at(pos)
	var travel_time:float = self.global_position.distance_to(pos) * time_per_meter / projectile_speed
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", pos, travel_time)
	
	await tween.finished
	hit_target.emit()
	_on_hit()

#Override this
func _on_hit() -> void:
	queue_free()
