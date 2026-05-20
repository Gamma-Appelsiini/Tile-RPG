@tool
extends Node
class_name TileCreator
#Tool to create tiles for levels

@export var tile_manager:TileManager = null
@export var start_node:Node3D = null
@export var end_node:Node3D = null

@export var create_frags_button := false:
	set(value):
		if value:
			_add_tiles()
			create_frags_button = false
			print("Added tiles")

const OFFSETS:Array[Vector3] = [Vector3(0,0,-1),Vector3(0,0,1),Vector3(-1,0,0),Vector3(1,0,0)]

var created_tiles:Array[Tile] = []

func _clear_tiles() -> void:
	created_tiles = []
	for child:Tile in tile_manager.get_children():
		child.queue_free()

func _add_tiles() -> void:
	if !Engine.is_editor_hint(): return
	_clear_tiles()
	
	var x:float = start_node.global_position.x
	var y:float = start_node.global_position.y
	var z:float = start_node.global_position.z
	
	while x <= end_node.global_position.x:
		z = start_node.global_position.z
		while z <= end_node.global_position.z:
			var from:Vector3 = Vector3(x,y + 5,z)
			var result:Dictionary = _shoot_ray(from)
			if result.is_empty():
				z += 1
				continue
			var hit_pos:Vector3 = result["position"]
			var rounded_x:int = int(hit_pos.x)
			var rounded_z:int = int(hit_pos.z)
			var rounded_pos:Vector3 = Vector3(rounded_x,hit_pos.y,rounded_z)
			_add_tile(rounded_pos, result["normal"])
			z += 1
		x += 1

func _shoot_ray(from:Vector3) -> Dictionary:
	var space := start_node.get_world_3d().direct_space_state
	var to = from + Vector3.DOWN * 50
	var ray_query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	
	ray_query.collision_mask = 1
	ray_query.from = from
	ray_query.to = to
	var raycast_result := space.intersect_ray(ray_query)
	return raycast_result
	
func _add_tile(pos:Vector3, normal:Vector3) -> void:
	var new_tile:Tile = Tile.new()
	created_tiles.push_back(new_tile)
	tile_manager.add_child(new_tile)
	new_tile.owner = get_tree().edited_scene_root
	new_tile.global_position = pos
	#TODO this is not saved
	new_tile.surface_normal = normal
	#if normal != Vector3.UP: print("Ramp: ", pos, " normal: ", normal, "Name: ", new_tile)
