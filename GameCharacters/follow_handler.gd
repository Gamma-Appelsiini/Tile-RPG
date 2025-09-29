extends Node
class_name FollowHandler

@export var area:Area3D

var tile_manager:TileManager = null
var target:GameCharacter = null
var target_tile:Tile = null
var path:Array[Tile] = []
var follower:GameCharacter = null

var stop_distance:float = 0.9
var time_per_meter:float = 0.8
var following:bool = false
var pathing:bool = false

func _ready() -> void:
	if get_parent() is GameCharacter: follower = get_parent() as GameCharacter
	area.body_entered.connect(_area_entered)
	
func _area_entered(body:Node3D) -> void:
	if body is Player:
		area.set_deferred("monitoring",false)
		set_target(body)
		start_follow()

func set_target(new_target:GameCharacter) -> void:
	target = new_target
	
func set_tile_manager(new_tilem:TileManager) -> void:
	tile_manager = new_tilem
	
func start_follow() -> void:
	if target == null:
		print("NO TARGET FOR FOLLOWING")
		return
	following = false
	_wait_to_follow()

func _wait_to_follow() -> void:
	if following: return
	target_tile = null
	
	if target.velocity != Vector3.ZERO or follower.global_position.distance_to(target.global_position) > 1:
		following = true
		await get_tree().create_timer(0.4).timeout
		_get_target_tile()
		_move_follower()
		return
	
	await get_tree().create_timer(0.35).timeout
	_wait_to_follow()


func _path_to_target_tile() -> void:
	var starting_tile:Tile = tile_manager.get_closest_tile(follower.global_position)
	if starting_tile.global_position.distance_to(follower.global_position) > 0.1:
		tile_manager.set_on_closest_tile(follower,true)
		await follower.move_complete
	path = tile_manager.get_shortest_path(starting_tile, target_tile, true)
	path.pop_front()
	path.pop_back()
	
func _move_follower() -> void:
	if !following:
		target_tile = null
		_wait_to_follow()
		return
		
	_get_target_tile()
	if path == []:
		target_tile = null
		following = false
		_wait_to_follow()
		return
	
	var next_point:Vector3 = path.pop_front().global_position
	follower.move_to_point(next_point)
	
	await follower.move_complete
	_move_follower()

func _get_target_tile() -> void:
	var new_tile:Tile = tile_manager.get_closest_tile(target.global_position)
	if new_tile == null:
		await get_tree().create_timer(0.4).timeout
		following = false
		_wait_to_follow()
		return
	if follower.global_position.distance_to(new_tile.global_position) <= stop_distance:
		following = false
		_wait_to_follow()
	elif new_tile != target_tile:
		target_tile = new_tile
		_path_to_target_tile()
		
