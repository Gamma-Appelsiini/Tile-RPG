extends Node
class_name TileManager

signal character_moved

const PATH_VISUAL_SCENE:PackedScene = preload("uid://b0o02dka0wxp2")
const OFFSETS:Array[Vector3] = [Vector3(0,0,-1),Vector3(0,0,1),Vector3(-1,0,0),Vector3(1,0,0)]
const GROUND_INDICATOR_SCENE:PackedScene = preload("uid://od3hhc5xdir8")

var tiles:Dictionary[Vector3,Tile] = {}
var char_tiles:Dictionary[GameCharacter,Tile] = {}
var path_visuals:Array[PathVisual] = []

var player:Player = null
var player_camera:Camera3D = null
var shooting:bool = false
var shooting_ok:bool = true
var hovered_tile:Tile = null
var targeting_ability:bool = false

var ground_indicator:GroundIndicator = null

func _ready() -> void:
	#GlobalSignals.combat_start.connect(_on_combat_start)
	
	_create_new_path_visuals(8)
	_create_indicator()
	
	for tile:Tile in get_children():
		tiles[tile.global_position] = tile
		tile.tile_manager = self
		
	for tile:Tile in tiles.values():
		_add_neighbors(tile)
		_add_diagonals(tile)

func _on_combat_start() -> void:
	var current_level:Level = GlobalSignals.current_level
	#set_on_closest_tile(player,false)
	
	#TODO change to only put combat chars
	for gchar:GameCharacter in current_level.game_chars:
		#set_on_closest_tile(gchar,false)
		pass

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

func _set_char_on_tile(game_char:GameCharacter, new_tile:Tile)-> void:

	if char_tiles.has(game_char):
		var prev_tile:Tile = char_tiles[game_char]
		prev_tile.occupant = null
		prev_tile.blocked = false
		
	new_tile.occupant = game_char
	new_tile.blocked = true
	char_tiles[game_char] = new_tile
	game_char.moved_to_tile.emit(new_tile)

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
		if neighbor != null: tile.neighbor_tiles.push_back(neighbor)

func _add_diagonals(tile:Tile) -> void:
	var topl:Tile = tiles.get(tile.global_position + (OFFSETS[1] + OFFSETS[2]))
	var topr:Tile = tiles.get(tile.global_position + (OFFSETS[1] - OFFSETS[3]))
	var botl:Tile = tiles.get(tile.global_position + (OFFSETS[0] + OFFSETS[2]))
	var botr:Tile = tiles.get(tile.global_position + (OFFSETS[0] - OFFSETS[3]))
	
	var left:Tile = tiles.get(tile.global_position + OFFSETS[0])
	var right:Tile = tiles.get(tile.global_position + OFFSETS[1])
	var top:Tile = tiles.get(tile.global_position + OFFSETS[2])
	var bot:Tile = tiles.get(tile.global_position + OFFSETS[3])
	
	if topl != null and left != null and right != null:
		tile.diagonal_tiles.push_back(topl)
		
	if topr != null and top != null and left != null:
		tile.diagonal_tiles.push_back(topr)
		
	if botl != null and left != null and bot != null:
		tile.diagonal_tiles.push_back(botl)
		
	if botr != null and bot != null and right != null:
		tile.diagonal_tiles.push_back(botr)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if hovered_tile != null and shooting_ok and !targeting_ability:
			_move_character_to_tile(player, hovered_tile)
			disable_shooting()
			await character_moved
			enable_shooting()

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
	if hovered_tile == new_tile:
		return
	if new_tile == null:
		ground_indicator.visible = false
		_hide_path()
		hovered_tile = null
		return
	
	hovered_tile = new_tile
	ground_indicator.visible = true
	ground_indicator.global_position = new_tile.global_position
	if hovered_tile.blocked or hovered_tile.occupant != null: ground_indicator.set_indicator_color(false)
	else: ground_indicator.set_indicator_color(true)
	
	var player_move_amount:int = player.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT]
	var path:Array[Tile] = get_shortest_path(char_tiles[player as GameCharacter], hovered_tile)
	path = path.slice(0,player_move_amount + 1)
	_visualize_path(path)

func _choose_tile() -> void:
	if !shooting: return
	
	if shooting_ok and !targeting_ability:
		var mouse_point:Vector3 = _get_mouse_point()
		var closest_tile:Tile = get_closest_tile(mouse_point)
		_set_hovered_tile(closest_tile)
	else:
		ground_indicator.visible = false
		_hide_path()
		
	await get_tree().create_timer(0.1).timeout
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
	var rounded_y:int = int((pos.y))
	var rounded_pos:Vector3 = Vector3((rounded_x),rounded_y,(rounded_z))
	
	if tiles.has(rounded_pos): closest_tile = tiles[rounded_pos]
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
	
func get_tiles_in_range(start:Tile, range_amount:int, allow_diagonal:bool = false) -> Array[Tile]:
	var possible_tiles:Array[Tile] = []
	for tile:Tile in tiles.values():
		if get_tile_distance(start, tile) <= range_amount: possible_tiles.push_back(tile)
	
	var tiles_in_range:Array[Tile] = []
	for tile:Tile in tiles_in_range:
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

func _hide_path() -> void:
	for visual:PathVisual in path_visuals:
		visual.hide_visual()

func _create_new_path_visuals(path_length:int) -> void:
	while path_length > len(path_visuals):
		var new_pv:PathVisual = PATH_VISUAL_SCENE.instantiate()
		get_parent().add_child.call_deferred(new_pv)
		new_pv.hide_visual()
		path_visuals.push_back(new_pv)

func _visualize_path(path:Array[Tile]) -> void:
	_create_new_path_visuals(len(path))
	_hide_path()
	
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
		var path_visual:PathVisual = path_visuals[i]
		path_visual.global_position = tile.global_position
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
		
		path_visual.show_visual(visual_type)
		path_visual.set_visual_rotation(rotation_amount)
		
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
