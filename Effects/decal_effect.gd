extends Decal
class_name DecalEffect


func _spawn_decal() -> void:
	var collision_pos:Vector3 = Vector3.ZERO
	var from := global_position
	var to := global_position + Vector3.DOWN * 2.0
	
	# Only collide with layers 1, 2, 3  → bitmask: (1<<0) | (1<<1) | (1<<2) = 0b00000111 = 7
	var mask := 0b00000111
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = mask
	var result := space_state.intersect_ray(query)
	
	if result:
		collision_pos = result.position
		self.global_position = collision_pos
	else: self.visible = false
