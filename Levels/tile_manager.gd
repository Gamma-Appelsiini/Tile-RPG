extends Node3D
class_name TileManager

signal character_moved

@export var door_node:Node = null

const PATH_VISUAL_SCENE:PackedScene = preload("uid://b0o02dka0wxp2")
const OFFSETS:Array[Vector3] = [Vector3(0,0,-1),Vector3(0,0,1),Vector3(-1,0,0),Vector3(1,0,0)]
const GROUND_INDICATOR_SCENE:PackedScene = preload("uid://od3hhc5xdir8")

var tiles:Dictionary[Vector3,Tile] = {}
var char_tiles:Dictionary[GameCharacter,Tile] = {}
var path_visuals:Array[PathVisual] = []
var doors:Array[Door] = []

var player:Player = null
var player_camera:Camera3D = null
var shooting:bool = false
var shooting_ok:bool = true
var hovered_tile:Tile = null
var targeting_ability:bool = false

var ground_indicator:GroundIndicator = null

func _add_doors() -> void:
	for new_door:Door in door_node.get_children():
		doors.push_back(new_door)
		new_door.add_blocked_tiles(self)


func _ready() -> void:
	set_process_input(false)
	_create_new_path_visuals(8)
	_create_indicator()
	
	for tile:Tile in get_children():
		tiles[tile.global_position] = tile
		tile.tile_manager = self
		
	for tile:Tile in tiles.values():
		_add_neighbors(tile)
		_add_diagonals(tile)
		
	_add_doors()
	
	GlobalSignals.load_game.connect(disable_shooting)

func get_tiles_in_aoe(start_tile:Tile, aoe:int) -> Array[Tile]:
	var tiles_in_aoe:Array[Tile] = []
	_reset_tiles()
	tiles_in_aoe.push_back(start_tile)
	aoe -= 1

	var current_frontier: Array[Tile] = [start_tile]
	for i in range(aoe):
		var next_frontier: Array[Tile] = []
		for tile:Tile in current_frontier:
			for neighbor:Tile in tile.neighbor_tiles:
				if !neighbor.visited:
					neighbor.visited = true
					next_frontier.append(neighbor)
					tiles_in_aoe.append(neighbor)
		if next_frontier.is_empty():
			break
		current_frontier = next_frontier

	return tiles_in_aoe

func _create_indicator() -> void:
	ground_indicator = GROUND_INDICATOR_SCENE.instantiate()
	ground_indicator.visible = false
	get_parent().add_child.call_deferred(ground_indicator)

func _set_char_on_tile(game_char:GameCharacter, new_tile:Tile) -> void:

	if char_tiles.has(game_char):
		var prev_tile:Tile = char_tiles[game_char]
		prev_tile.occupant = null
		prev_tile.blocked = false
		
		prev_tile.tile_left.emit(game_char)
		
	new_tile.occupant = game_char
	new_tile.blocked = true
	char_tiles[game_char] = new_tile
	
	game_char.moved_to_tile.emit(new_tile)
	new_tile.tile_entered.emit(game_char)

func remove_char_from_its_tile(game_char:GameCharacter) -> void:
	if char_tiles.has(game_char):
		char_tiles[game_char].occupant = null
		char_tiles[game_char].blocked = false

func move_character_to_character(move_char:GameCharacter, target_char:GameCharacter) -> void:
	var path:Array[Tile] = get_shortest_path(char_tiles[move_char], char_tiles[target_char], false, true)
	path.pop_front()
	path.pop_back()
	_use_movement_to_traverse_tile_path(move_char, path)

func _use_movement_to_traverse_tile_path(move_char:GameCharacter, path:Array[Tile]) -> void:
	if path == [] or move_char.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT] == 0:
		await get_tree().create_timer(0.1).timeout
		character_moved.emit()
		return
	
	for tile:Tile in path:
		var char_move_amount:int = move_char.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT]
		if 0 >= char_move_amount: break
		
		var start:bool = false
		var end:bool = false
		if tile == path.back(): end = true
		if tile == path.front(): start = true
		if char_move_amount == 1: end = true
		
		move_char.move_to_point(tile.global_position,start, end)
		move_char.stat_handler.update_stat(Stats.ResourceStat.CURRENT_MOVEMENT, -1)
		await move_char.move_complete
		
		_set_char_on_tile(move_char, tile)
	
	character_moved.emit()

func _move_character_to_tile(game_character:GameCharacter,end_tile:Tile, end_tile_can_be_blocked:bool = false) -> void:
	var path:Array[Tile] = get_shortest_path(char_tiles[game_character], end_tile, false, end_tile_can_be_blocked)
	path.pop_front()
	
	_use_movement_to_traverse_tile_path(game_character, path)

func _add_neighbors(tile:Tile) -> void:
	for offset:Vector3 in OFFSETS:
		var neighbor:Tile = tiles.get(tile.global_position + offset)
		if neighbor != null:
			if !_check_if_wall_between_tiles(tile, neighbor):
				tile.neighbor_tiles.push_back(neighbor)
	
	if tile.surface_normal != Vector3.UP: _add_ramp_neighbors(tile)
	#if tile.global_position == Vector3(5.0, 0.25, 2.0): _add_ramp_neighbors(tile)

func _add_ramp_neighbors(tile:Tile) -> void:
	const y_offset:float = 0.25
	var up_offset := Vector3.ZERO
	var down_offset := Vector3.ZERO

	# Check if the ramp is sloped along the X axis or the Z axis
	if abs(tile.surface_normal.x) > abs(tile.surface_normal.z):
		# Normal tilts left (-X) -> Ramp climbs right (+X)
		if tile.surface_normal.x < 0:
			up_offset = Vector3(1, 0, 0)
			down_offset = Vector3(-1, 0, 0)
			# Normal tilts right (+X) -> Ramp climbs left (-X)
		else:
			up_offset = Vector3(-1, 0, 0)
			down_offset = Vector3(1, 0, 0)
	else:
		# Normal tilts forward (-Z) -> Ramp climbs backward (+Z)
		if tile.surface_normal.z < 0:
			up_offset = Vector3(0, 0, 1)
			down_offset = Vector3(0, 0, -1)
			# Normal tilts backward (+Z) -> Ramp climbs forward (-Z)
		else:
			up_offset = Vector3(0, 0, -1)
			down_offset = Vector3(0, 0, 1)

	# CHECK UPWARD NEIGHBOR (+y_offset)
	var up_neighbor:Tile = self.tiles.get(tile.global_position + up_offset + Vector3(0, y_offset, 0))
	if up_neighbor != null:
		tile.neighbor_tiles.push_back(up_neighbor)
		# Force the two-way connection so the upper tile doesn't have to look for this ramp
		if not up_neighbor.neighbor_tiles.has(tile):
			up_neighbor.neighbor_tiles.push_back(tile)
			
	# CHECK DOWNWARD NEIGHBOR (-y_offset)
	var down_neighbor:Tile = self.tiles.get(tile.global_position + down_offset + Vector3(0, -y_offset, 0))
	if down_neighbor != null:
		tile.neighbor_tiles.push_back(down_neighbor)
		# Force the two-way connection so the lower tile doesn't have to look for this ramp
		if not down_neighbor.neighbor_tiles.has(tile):
			down_neighbor.neighbor_tiles.push_back(tile)
			

func _check_if_wall_between_tiles(tile_from:Tile, tile_to:Tile) -> bool:
	const vertical_offset:Vector3 = Vector3(0,1,0)
	var space_state:PhysicsDirectSpaceState3D  = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(tile_from.global_position + vertical_offset, tile_to.global_position + vertical_offset)
	
	# Only collide with layer 2, walls
	query.collision_mask = 1 << 1
	
	var result := space_state.intersect_ray(query)
	return !result.is_empty()

func _add_diagonals(tile: Tile) -> void:
	var n_front:Tile = tiles.get(tile.global_position + Vector3(0, 0, 1))
	var n_back:Tile  = tiles.get(tile.global_position + Vector3(0, 0, -1))
	var n_left:Tile  = tiles.get(tile.global_position + Vector3(-1, 0, 0))
	var n_right:Tile = tiles.get(tile.global_position + Vector3(1, 0, 0))

	var d_front_left:Tile  = tiles.get(tile.global_position + Vector3(-1, 0, 1))
	var d_front_right:Tile = tiles.get(tile.global_position + Vector3(1, 0, 1))
	var d_back_left:Tile   = tiles.get(tile.global_position + Vector3(-1, 0, -1))
	var d_back_right:Tile  = tiles.get(tile.global_position + Vector3(1, 0, -1))

	if d_front_left and n_front and n_left and tile.neighbor_tiles.has(n_front) and tile.neighbor_tiles.has(n_left):
		if !_check_if_wall_between_tiles(d_front_left, n_front) and !_check_if_wall_between_tiles(d_front_left, n_left):
			tile.diagonal_tiles.push_back(d_front_left)
		
	if d_front_right and n_front and n_right and tile.neighbor_tiles.has(n_front) and tile.neighbor_tiles.has(n_right):
		if !_check_if_wall_between_tiles(d_front_right, n_front) and !_check_if_wall_between_tiles(d_front_right, n_right):
			tile.diagonal_tiles.push_back(d_front_right)
		
	if d_back_left and n_back and n_left and tile.neighbor_tiles.has(n_back) and tile.neighbor_tiles.has(n_left):
		if !_check_if_wall_between_tiles(d_back_left, n_back) and !_check_if_wall_between_tiles(d_back_left, n_left):
			tile.diagonal_tiles.push_back(d_back_left)
		
	if d_back_right and n_back and n_right and tile.neighbor_tiles.has(n_back) and tile.neighbor_tiles.has(n_right):
		if !_check_if_wall_between_tiles(d_back_right, n_back) and !_check_if_wall_between_tiles(d_back_right, n_right):
			tile.diagonal_tiles.push_back(d_back_right)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if hovered_tile != null and shooting_ok and !targeting_ability and !_is_mouse_pos_below_percentage():
			_move_character_to_tile(player, hovered_tile)
			disable_shooting()
			await character_moved
			enable_shooting()
	if event.is_action_pressed("Middle Mouse"):
		if hovered_tile:
			print("tile pos: ", hovered_tile.global_position)


func enable_shooting() -> void:
	set_process_input(true)
	shooting = true
	_choose_tile()
	
func disable_shooting() -> void:
	shooting = false
	_hide_path()
	set_process_input(false)
	_set_hovered_tile(null)

func _set_hovered_tile(new_tile:Tile) -> void:
	if new_tile == null:
		ground_indicator.visible = false
		_hide_path()
		hovered_tile = null
		return
		
	if hovered_tile == new_tile:
		if !recreate_path: return
	
	hovered_tile = new_tile
	ground_indicator.visible = true
	ground_indicator.global_position = new_tile.global_position

	var alignment_quat:Quaternion = Quaternion(Vector3.UP, hovered_tile.surface_normal)
	ground_indicator.transform.basis = Basis(alignment_quat)
	
	if hovered_tile.blocked or hovered_tile.occupant != null: ground_indicator.set_indicator_color(false)
	else: ground_indicator.set_indicator_color(true)
	
	var player_move_amount:int = player.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT]
	var path:Array[Tile] = get_shortest_path(char_tiles[player as GameCharacter], hovered_tile)
	path = path.slice(0,player_move_amount + 1)
	_visualize_path(path)

func _is_mouse_pos_below_percentage(percentage:float = 10.0) -> bool:
	var viewport_height:float = get_viewport().get_visible_rect().size.y
	var mouse_y:float = get_viewport().get_mouse_position().y
	
	var threshold:float = viewport_height * (1.0 - (percentage / 100.0))
	return (mouse_y >= threshold)

func _choose_tile() -> void:
	if !shooting: return

	if shooting_ok and !targeting_ability and !_is_mouse_pos_below_percentage():
		var mouse_point:Vector3 = _get_mouse_point()
		var closest_tile:Tile = get_closest_tile(mouse_point)
		_set_hovered_tile(closest_tile)
	else:
		ground_indicator.visible = false
		_hide_path()
		
	await get_tree().create_timer(0.05).timeout
	_choose_tile()

func _get_mouse_point() -> Vector3:
	var point:Vector3 = Vector3.INF
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + current_camera.project_ray_normal(mouse_pos) * 2000.0
	
	var space_state := player.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	
	#Collide with only floors
	query.collision_mask = 1 << 0
	
	var result := space_state.intersect_ray(query)
	if result: point = result.position
	
	return point

func get_closest_tile(pos:Vector3) -> Tile:
	var closest_tile:Tile = null
	if pos == Vector3.INF: return closest_tile
	
	var rounded_x:int = int(round(pos.x))
	var rounded_z:int = int(round(pos.z))
	var rounded_y:float = round(pos.y / 0.25) * 0.25
	var rounded_pos:Vector3 = Vector3((rounded_x),rounded_y,(rounded_z))
	
	if tiles.has(rounded_pos): closest_tile = tiles[rounded_pos]
	else:
		if tiles.has(rounded_pos + Vector3(0,0.25,0)): closest_tile = tiles[rounded_pos + Vector3(0,0.25,0)]
		elif tiles.has(rounded_pos + Vector3(0,-0.25,0)): closest_tile = tiles[rounded_pos + Vector3(0,-0.25,0)]
	return closest_tile
	
func set_player(new_player:Player) -> void:
	player = new_player
	player_camera = new_player.player_camera

func _reset_tiles() -> void:
	for tile:Tile in tiles.values():
		tile.reset_tile()

func get_tile_distance(start:Tile, end:Tile, allow_diagonal:bool = false) -> int:
	if allow_diagonal: int(max( abs(start.global_position.x - end.global_position.x), abs(start.global_position.z - end.global_position.z)))
	return int(abs(start.global_position.x - end.global_position.x) + abs(start.global_position.z - end.global_position.z))
	
func get_tiles_in_range(start:Tile, range_amount:int, allow_diagonal:bool = false, use_raycast:bool = false	) -> Array[Tile]:
	var possible_tiles:Array[Tile] = []
	for tile:Tile in tiles.values():
		if tile == start: continue
		if get_tile_distance(start, tile) <= range_amount: possible_tiles.push_back(tile)
	
	var tiles_in_range:Array[Tile] = []
	for tile:Tile in possible_tiles:
		if get_shortest_path(start, tile, allow_diagonal, true) != []: tiles_in_range.push_back(tile)
	
	return tiles_in_range

#TODO edge cases
func get_distance_to_tile(start:Tile, end:Tile, _allow_diagonal:bool = false) -> int:
	var path:Array[Tile] = get_shortest_path(start,end, false, true)
	return len(path) - 1

func get_shortest_path(start:Tile, end:Tile, out_of_combat:bool = false, end_tile_can_be_blocked:bool = false)->Array[Tile]:
	if start == end: return []
	var path:Array[Tile] = []
	_reset_tiles()
	
	#BFS
	var queue: Array[Tile] = [start]
	var current: Tile = null
	start.visited = true
	
	while queue.size() > 0:
		current = queue.pop_front()
		
		if current == end:
			break
		
		var neighbors:Array[Tile] = current.neighbor_tiles
		if out_of_combat: neighbors.append_array(current.diagonal_tiles)
		
		for neighbor:Tile in neighbors:
			if end_tile_can_be_blocked:
				if neighbor == end:
					neighbor.visited = true
					neighbor.came_from = current
					queue.push_back(neighbor)
					break
			
			if neighbor.blocked or neighbor.occupant != null: continue
			if !neighbor.visited:
				neighbor.visited = true
				neighbor.came_from = current
				queue.push_back(neighbor)
	
	if current != end: return []
	
	current = end
	while current != null:
		path.push_back(current)
		current = current.came_from
	
	path.reverse()
	return path

var recreate_path:bool = false
func _hide_path() -> void:
	for visual:PathVisual in path_visuals:
		visual.hide_visual()
	recreate_path = true

func get_character_tile(game_char:GameCharacter) -> Tile:
	if !char_tiles[game_char]: return null
	
	return char_tiles[game_char]

func _create_new_path_visuals(path_length:int) -> void:
	while path_length > len(path_visuals):
		var new_pv:PathVisual = PATH_VISUAL_SCENE.instantiate()
		get_parent().add_child.call_deferred(new_pv)
		new_pv.hide_visual()
		path_visuals.push_back(new_pv)

var old_path:Array[PathVisual] = []
func _visualize_path(path:Array[Tile]) -> void:
	_create_new_path_visuals(len(path))
	_hide_path()
	recreate_path = false
	
	#Visualization starts after first tile
	for i in range(1, path.size()):
		var tile:Tile = path[i]
		var prev_tile:Tile = path[i - 1]
		var next_tile:Tile = null
		if i + 1 < path.size(): next_tile = path[i + 1]
		
		var prev_dir:Vector3 = (tile.global_position - prev_tile.global_position).normalized()
		var next_dir:Vector3 = Vector3.ZERO
		if next_tile: next_dir = (next_tile.global_position - tile.global_position).normalized()
		
		var rotation_amount:float = 0
		var path_visual:PathVisual = path_visuals[i-1]
		path_visual.global_position = tile.global_position
		var alignment_quat:Quaternion = Quaternion(Vector3.UP, tile.surface_normal)
		path_visual.transform.basis = Basis(alignment_quat)
		var visual_type:PathVisual.VISUAL
		
		if next_tile == null:
			visual_type = PathVisual.VISUAL.ARROW
			#Needs a hack due to mesh origin rotation
			rotation_amount = -atan2(prev_dir.x, prev_dir.z)
			if rad_to_deg(rotation_amount) == 0:
				rotation_amount = deg_to_rad(180)
			elif rad_to_deg(rotation_amount) == -180:
				rotation_amount = deg_to_rad(0)
		elif abs(prev_dir.dot(next_dir)) > 0.9:
			visual_type = PathVisual.VISUAL.STRAIGTH
			rotation_amount = atan2(prev_dir.x, prev_dir.z)
		else:
			visual_type = PathVisual.VISUAL.CORNER
			rotation_amount = _get_corner_rotation(prev_tile, tile, next_tile)
		
		path_visual.set_visual_rotation(rotation_amount)
		path_visual.show_visual(visual_type)
		
func _get_corner_rotation(prev_tile:Tile, tile:Tile, next_tile:Tile) -> float:
	var rotation_amount:float = 0
	var p := Vector2(prev_tile.global_position.x, prev_tile.global_position.z)
	var c := Vector2(tile.global_position.x, tile.global_position.z)
	var n := Vector2(next_tile.global_position.x, next_tile.global_position.z)
	var dir1:Vector2 = (c-p)
	var dir2:Vector2 = (n-c)
	
	if dir1 == Vector2(0,1) and dir2 == Vector2(1,0):
		rotation_amount = 90
	elif dir1 == Vector2(0,1) and dir2 == Vector2(-1,0):
		rotation_amount = 180
	elif dir1 == Vector2(0,-1) and dir2 == Vector2(-1,0):
		rotation_amount = -90
	elif dir1 == Vector2(1,0) and dir2 == Vector2(0,1):
		rotation_amount = 270
	elif dir1 == Vector2(1,0) and dir2 == Vector2(0,-1):
		rotation_amount = 180
	elif dir1 == Vector2(0,-1) and dir2 == Vector2(1,0):
		rotation_amount = 0
	elif dir1 == Vector2(-1,0) and dir2 == Vector2(0,-1):
		rotation_amount = 90

	return deg_to_rad(rotation_amount)

func reset() -> void:
	for tile:Tile in tiles.values():
		if tile.occupant:
			tile.occupant = null
			tile.blocked = false
	char_tiles = {}

func set_on_closest_tile(game_char:GameCharacter, out_of_combat:bool = false) -> void:
	var distance:float = -1
	var closest_tile:Tile = null
	
	for tile:Tile in tiles.values():
		if tile.blocked: continue
		if distance == -1:
			distance = game_char.global_position.distance_to(tile.global_position)
			closest_tile = tile
			continue

		var new_distance:float = game_char.global_position.distance_to(tile.global_position)
		if new_distance >= distance: continue
		
		distance = new_distance
		closest_tile = tile
		
	if closest_tile == null:
		print("ERROR: NO TILE FOUND FOR ", char)
		return

	game_char.move_to_point(closest_tile.global_position,true,true)
	await game_char.move_complete
	if !out_of_combat: _set_char_on_tile(game_char, closest_tile)
