@tool
extends Node
class_name SpotCreator

@export var create_spots_button := false:
	set(value):
		if value:
			_add_spots()
			create_spots_button = false
			print("Added spots")

func _add_spots() -> void:
	for node: Node3D in get_children():
		var shoot_pos: Vector3 = node.global_position + Vector3(0, 0, 1)
		var target_pos: Vector3 = node.global_position
		var space_state: PhysicsDirectSpaceState3D = node.get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(shoot_pos, target_pos)

		var result: Dictionary = space_state.intersect_ray(query)
		
		if result:
			print("Node: ", node.name)
			print(" - Collision Spot: ", result["position"])
			print(" - Normal Vector: ", result["normal"])
		else:
			print("Node: ", node.name, " - No collision detected.")
