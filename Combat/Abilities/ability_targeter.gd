extends Node
class_name AbilityTargeter

const AOE_INDICATOR:PackedScene = preload("uid://mn3gwrbcqycm")
const RANGE_INDICATOR := preload("uid://ff1heogqgu75")
#Using & before the strings makes them StringName types
const NON_CANCELLING_ACTIONS: Array[StringName] = [
	&"Zoom In", &"Zoom Out", &"Backward", &"Forward", 
	&"Left", &"Right", &"Rotate Cam L", &"Rotate Cam R",
	&"ability 0", &"ability 1", &"ability 2", &"ability 3", 
	&"ability 4", &"ability 5", &"ability 6", &"ability 7", 
	&"ability 8", &"ability 9",
]
const RANGE_MESH_MATERIAL := preload("uid://ckgonjkqks5ra")

var player:Player = null
var tile_manager:TileManager = null

var selected_ability:Ability = null
var selected_slot:AbilitySlot = null
var hovered_character:GameCharacter = null
var hovered_tile:Tile = null
var aoe_indicators:Array[Node3D] = []
var range_indicators:Array[RangeIndicator] = []
var hidden_indicators:Array[RangeIndicator] = []
var range_mesh:MeshInstance3D = null
var info_handler:AttackInfoHandler = null

func _ready() -> void:	
	set_process(false)
	set_process_input(false)
	_add_range_tiles(20)
	info_handler = AttackInfoHandler.new()
	add_child(info_handler)

func _start_targeting_animation() -> void:
	if selected_ability.targeting_animation == CharacterModelHandler.CharAnimation.NULL: return
	player.char_model_handler.play_animation(selected_ability.targeting_animation,false)
	
	if selected_ability.targeting_animation == CharacterModelHandler.CharAnimation.CASTING:
		player.char_model_handler.start_casting_effects()
		
func _stop_targeting_animation() -> void:
	player.char_model_handler.play_idle_animation()
	
	if selected_ability.targeting_animation == CharacterModelHandler.CharAnimation.CASTING:
		player.char_model_handler.stop_casting_effects()

func _add_range_tiles(amount:int) -> void:
	while len(range_indicators) < amount:
		var new_indicator:RangeIndicator = RANGE_INDICATOR.instantiate()
		range_indicators.push_back(new_indicator)
		new_indicator.hide()
		add_child(new_indicator)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"): 
		_use_ability()
	#Any other action other than camera movement in input map cancels
	elif _is_input_non_cancelling(event):
		return
	elif event.is_pressed() and not event.is_echo():
		cancel_ability_targeting()

func _is_input_non_cancelling(event: InputEvent) -> bool:
	return NON_CANCELLING_ACTIONS.any(func(action): return event.is_action_pressed(action))


func _process(_delta: float) -> void:
	_get_ability_target()

func _hide_range_indicators() -> void:
	if !range_mesh: return
	
	range_mesh.hide()
	range_mesh.queue_free()
	range_mesh = null

func _show_attack_info_for_aoe(tiles_in_aoe:Array[Tile]) -> void:
	var game_chars_in_aoe:Array[GameCharacter] = []
	for tile:Tile in tiles_in_aoe:
		if tile.occupant: game_chars_in_aoe.push_back(tile.occupant)
	
	info_handler.show_info_on_characters(game_chars_in_aoe, selected_ability)

func _visualize_aoe() -> void:
	var tiles_in_aoe:Array[Tile] = selected_ability.get_tiles_in_aoe(hovered_tile)
	if selected_ability.target_type == Ability.TARGET_TYPE.NONE: tiles_in_aoe = tile_manager.get_tiles_in_aoe(tile_manager.char_tiles[selected_ability.ability_owner], selected_ability.ability_aoe)
	elif tiles_in_aoe == [null]: tiles_in_aoe = tile_manager.get_tiles_in_aoe(hovered_tile, selected_ability.ability_aoe)
	_show_attack_info_for_aoe(tiles_in_aoe)
	
	for i:int in len(tiles_in_aoe):
		var indicator:RangeIndicator = range_indicators[i]
		var alignment_quat:Quaternion = Quaternion(Vector3.UP, tiles_in_aoe[i].surface_normal)
		indicator.transform.basis = Basis(alignment_quat)
		indicator.global_position = tiles_in_aoe[i].global_position + Vector3(0,0.05,0)
		if tiles_in_aoe[i].occupant:
			indicator.set_enemy_color()
		indicator.show()

func _visualize_tiles_in_range() -> void:
	if selected_ability.target_type == Ability.TARGET_TYPE.NONE: return
	
	var player_tile:Tile = tile_manager.char_tiles[player]
	var tiles_in_range:Array[Tile] = tile_manager.get_tiles_in_range(player_tile, selected_ability.get_range())
	_add_range_tiles(len(tiles_in_range))
	
	tiles_in_range.push_back(player_tile)
	range_mesh = _create_array_mesh(tiles_in_range, player_tile)
	range_mesh.material_override = RANGE_MESH_MATERIAL

func set_ability_to_target(new_slot:AbilitySlot) -> void:
	#TODO HERE
	var new_ability:Ability = new_slot.ability_in_slot
	
	if new_ability == null:
		cancel_ability_targeting()
		return
	
	if selected_ability == new_ability or selected_slot == new_slot: 
		cancel_ability_targeting()
		return
	elif selected_ability: cancel_ability_targeting()
	
	selected_ability = new_ability
	GlobalSignals.set_mouse_state.emit(MouseHandler.MOUSE_STATE.TARGETING)
	GlobalSignals.current_level.tile_manager.disable_shooting()
	selected_slot = new_slot
	selected_slot.glow_rect.show()
	
	if player == null:
		player = GlobalSignals.player

	_start_targeting_animation()
	_visualize_tiles_in_range()
	set_process(true)
	set_process_input(true)

func cancel_ability_targeting(enable_movement:bool = true) -> void:
	if selected_ability == null: return
	
	info_handler.hide_info()
	_stop_targeting_animation()
	_hide_range_indicators()
	set_process_input(false)
	set_process(false)
	_hide_aoe()
	
	selected_slot.glow_rect.hide()
	selected_slot = null
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_tile = null
	hovered_character = null
	selected_ability = null

	if enable_movement: GlobalSignals.current_level.tile_manager.enable_shooting()
	GlobalSignals.set_mouse_state.emit(MouseHandler.MOUSE_STATE.NORMAL)

func _set_collision_mask(query:PhysicsRayQueryParameters3D) -> void:
	if selected_ability.target_type == Ability.TARGET_TYPE.TILE:
		query.collision_mask = 1 << 0
	elif selected_ability.target_type == Ability.TARGET_TYPE.GAME_CHARACTER:
		query.collision_mask = 1 << 3

func _get_ability_target() -> void:
	if selected_ability.target_type == Ability.TARGET_TYPE.TILE:
		var point:Vector3 = _get_mouse_point()
		if point != Vector3.INF:
			_set_new_target_tile(tile_manager.get_closest_tile(point))
	elif selected_ability.target_type == Ability.TARGET_TYPE.GAME_CHARACTER:
		_set_new_target_character(_get_hovered_character())
	elif selected_ability.target_type == Ability.TARGET_TYPE.NONE:
		_visualize_aoe()

func _set_new_target_tile(new_target:Tile) -> void:
	if hovered_tile == new_target: return

	info_handler.hide_info()
	_hide_aoe()
	hovered_tile = new_target
	_visualize_aoe()

func _hide_aoe() -> void:
	for aoe_ind:Node3D in aoe_indicators:
		aoe_ind.visible = false
		
	for ind:RangeIndicator in range_indicators:
		ind._reset_color()
		ind.hide()

func _create_array_mesh(tiles: Array[Tile], start_tile: Tile) -> MeshInstance3D:
	var new_mesh: MeshInstance3D = MeshInstance3D.new()
	var new_array_mesh: ArrayMesh = ArrayMesh.new()

	if tiles.is_empty() or not is_instance_valid(start_tile):
		return new_mesh

	# 1. Map the grid to easily find neighbors
	var grid := {}
	for tile in tiles:
		var local = tile.global_position - start_tile.global_position
		grid[Vector2(round(local.x), round(local.z))] = true

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()

	for tile in tiles:
		var offset = vertices.size()
		var local = tile.global_position - start_tile.global_position
		var pos = Vector2(round(local.x), round(local.z))

		# 2. Check 8 surrounding spaces (1 = Empty Space / Outer Boundary, 0 = Solid Neighbor)
		var mask: int = 0
		if not grid.has(pos + Vector2(0, -1)): mask |= 1    # Top
		if not grid.has(pos + Vector2(1, 0)):  mask |= 2    # Right
		if not grid.has(pos + Vector2(0, 1)):  mask |= 4    # Bottom
		if not grid.has(pos + Vector2(-1, 0)): mask |= 8    # Left
		if not grid.has(pos + Vector2(-1, -1)): mask |= 16  # Top-Left Corner
		if not grid.has(pos + Vector2(1, -1)):  mask |= 32  # Top-Right Corner
		if not grid.has(pos + Vector2(1, 1)):   mask |= 64  # Bottom-Right Corner
		if not grid.has(pos + Vector2(-1, 1)):  mask |= 128 # Bottom-Left Corner

		# 3. Pack the mask into a float (0.0 to 1.0) to send to the shader
		var color_val = float(mask) / 255.0
		var tile_color = Color(color_val, 0.0, 0.0, 1.0)
		
		#Normal
		var surf_normal: Vector3 = tile.surface_normal.normalized()
		var tilt_quat: Quaternion

		# Prevent Quaternion math errors if vectors are perfectly parallel or opposite
		if surf_normal.is_equal_approx(Vector3.UP):
			tilt_quat = Quaternion.IDENTITY
		elif surf_normal.is_equal_approx(Vector3.DOWN):
			tilt_quat = Quaternion(Vector3.RIGHT, PI) # Flip 180 degrees
		else:
			# Generate a rotation from the standard UP vector to our target normal
			tilt_quat = Quaternion(Vector3.UP, surf_normal)

		# 4. Build the Quad
		vertices.append_array([
			local + (tilt_quat * Vector3(-0.5, 0, -0.5)), # TL
			local + (tilt_quat * Vector3(-0.5, 0, 0.5)),  # BL
			local + (tilt_quat * Vector3(0.5, 0, 0.5)),   # BR
			local + (tilt_quat * Vector3(0.5, 0, -0.5))   # TR
		])

		normals.append_array([surf_normal, surf_normal, surf_normal, surf_normal])
		uvs.append_array([Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)])
		colors.append_array([tile_color, tile_color, tile_color, tile_color])

		indices.append_array([
			offset + 0, offset + 3, offset + 2, 
			offset + 0, offset + 2, offset + 1
		])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	new_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh.mesh = new_array_mesh

	add_child(new_mesh)
	new_mesh.global_position = start_tile.global_position + Vector3(0,0.05,0)

	return new_mesh

func _dist_to_segment(p: Vector2, v: Vector2, w: Vector2) -> float:
	var length_squared = v.distance_squared_to(w)
	if length_squared == 0.0: 
		return p.distance_to(v)
	var t = max(0.0, min(1.0, (p - v).dot(w - v) / length_squared))
	var projection = v + t * (w - v)
	return p.distance_to(projection)

func _show_aoe() -> void:
	var tiles_in_aoe:Array[Tile] = selected_ability.get_tiles_in_aoe(hovered_tile)
	if tiles_in_aoe == [null]: tiles_in_aoe = tile_manager.get_tiles_in_aoe(hovered_tile, selected_ability.ability_aoe)
	
	while len(tiles_in_aoe) > len(aoe_indicators):
		var new_indicator:Node3D = AOE_INDICATOR.instantiate()
		new_indicator.visible = false
		add_child(new_indicator)
		aoe_indicators.push_back(new_indicator)

	for indicator:Node3D in hidden_indicators: indicator.show()
	hidden_indicators = []
	
	for i:int in len(tiles_in_aoe):
		aoe_indicators[i].visible = true
		aoe_indicators[i].global_position = tiles_in_aoe[i].global_position
		_hide_range_indicator_in_aoe_visualization(aoe_indicators[i])
		
func _hide_range_indicator_in_aoe_visualization(aoe_indicator:Node3D) -> void:
	for indicator:Node3D in range_indicators:
		if indicator.visible and indicator.global_position == aoe_indicator.global_position:
			indicator.hide()
			hidden_indicators.push_back(indicator)

func _set_new_target_character(new_target:GameCharacter) -> void:
	if hovered_character == new_target: return
	
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_character = new_target
	GlobalSignals.show_outline_on_target.emit(hovered_character)
	
	_show_attack_info()
		
func _show_attack_info() -> void:
	if !hovered_character:
		info_handler.hide_info()
		return
	if !selected_ability: return
	
	info_handler.show_info_on_characters([hovered_character], selected_ability)

func _shoot_ray() -> Dictionary:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var current_camera:Camera3D = get_viewport().get_camera_3d()
	
	var from: Vector3 = current_camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + current_camera.project_ray_normal(mouse_pos) * 2000.0
	
	var space_state := player.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	_set_collision_mask(query)
	
	var result := space_state.intersect_ray(query)
	return result

func _get_mouse_point() -> Vector3:
	var point:Vector3 = Vector3.INF
	var result := _shoot_ray()
	if result: point = result.position
	
	return point

func _get_hovered_character() -> GameCharacter:
	var hovered_char:GameCharacter = null
	var result := _shoot_ray()
	if !result: return hovered_char
	
	if (result["collider"] is GameCharacter):
		hovered_char = result["collider"]
	
	return hovered_char

func _use_ability() -> void:
	var abi_to_use:Ability = selected_ability
	var tile_to_use_on:Tile = hovered_tile
	var char_to_use_on:GameCharacter = hovered_character
	cancel_ability_targeting(false)
	
	if abi_to_use.target_type == Ability.TARGET_TYPE.TILE:
		if tile_to_use_on != null:
			abi_to_use.use_ability_on_target_tile(tile_to_use_on)
			await abi_to_use.ability_finished
	elif abi_to_use.target_type == Ability.TARGET_TYPE.GAME_CHARACTER:
		if char_to_use_on != null:
			abi_to_use.use_ability_on_target_character(char_to_use_on)
			await abi_to_use.ability_finished
	elif abi_to_use.target_type == Ability.TARGET_TYPE.NONE:
		abi_to_use.use_ability()
		await abi_to_use.ability_finished
	
	GlobalSignals.current_level.tile_manager.enable_shooting()
	
