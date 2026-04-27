extends Interactable
class_name Door

@export var side_1:Node3D
@export var side_2:Node3D
@export var pivot:Node3D
@export var collision_shape_3d: CollisionShape3D = null

const OPEN_TIME:float = 0.55
#1.5708
const ROTATION_AMOUNT:float = -2.65

var door_rotation:float = 0
var return_rotation:float = 0
var locked:bool = false
var closest_interact:Node3D = null
var door_open:bool = false

var blocked_tiles:Array[Tile] = []

func add_blocked_tiles(tile_manager:TileManager) -> void:
	const OFFSETS:Array[Vector3] = [Vector3(0.5,0,0), Vector3(-0.5,0,0), Vector3(0,0,0.5), Vector3(0,0,-0.5)]

	for offset:Vector3 in OFFSETS:
		if tile_manager.tiles.has(self.global_position + offset):
			blocked_tiles.push_back(tile_manager.tiles[self.global_position + offset])
			
	_handle_blocked_tiles()

func interact() -> void:
	_handle_locked()
	if locked:
		await get_tree().create_timer(0.01).timeout
		interact_complete.emit()
		return
	interact_area.monitoring = false
	
	if used: door_rotation = return_rotation
	else:
		var distance_1:float = player.global_transform.origin.distance_to(side_1.global_transform.origin)
		var distance_2:float = player.global_transform.origin.distance_to(side_2.global_transform.origin)
		
		door_rotation = ROTATION_AMOUNT
		if distance_2 < distance_1:
			door_rotation *= -1
		return_rotation = door_rotation * -1
	
	used = !used
	
	if used:
		interact_text = "Close"
		door_open = true

	else:
		interact_text = "Open"
		door_open = false
		
	_handle_blocked_tiles()
	if !door_open: collision_shape_3d.disabled = false
	
	var tween:Tween = create_tween()
	tween.tween_property(pivot,"rotation",pivot.rotation +Vector3(0, door_rotation, 0), OPEN_TIME).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	if door_open: collision_shape_3d.disabled = true
	interact_area.monitoring = true
	interact_complete.emit()

func _handle_blocked_tiles() -> void:
	if len(blocked_tiles) != 2: return
	
	if !door_open:
		blocked_tiles[0].neighbor_tiles.erase(blocked_tiles[1])
		blocked_tiles[1].neighbor_tiles.erase(blocked_tiles[0])
	else:
		blocked_tiles[0].neighbor_tiles.push_back(blocked_tiles[1])
		blocked_tiles[1].neighbor_tiles.push_back(blocked_tiles[0])

#Overrided due to doors having 2 interact points
func get_interact_pos() -> Node3D:
	var distance_1:float = player.global_transform.origin.distance_to(side_1.global_transform.origin)
	var distance_2:float = player.global_transform.origin.distance_to(side_2.global_transform.origin)
	
	closest_interact = side_1
	if distance_2 < distance_1:
		closest_interact = side_2
		
	return closest_interact
	
#TODO add locked/key functionality
func _handle_locked() -> void:
	pass
