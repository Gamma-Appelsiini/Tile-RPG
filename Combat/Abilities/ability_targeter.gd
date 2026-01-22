extends Node
class_name AbilityTargeter

const AOE_INDICATOR:PackedScene = preload("uid://mn3gwrbcqycm")
const RANGE_INDICATOR := preload("uid://ff1heogqgu75")

var player:Player = null
var player_camera:Camera3D = null
var tile_manager:TileManager = null

var selected_ability:Ability = null
var hovered_character:GameCharacter = null
var hovered_tile:Tile = null
var aoe_indicators:Array[Node3D] = []
var input_ok:bool = false
var range_indicators:Array[RangeIndicator] = []

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	_add_range_tiles(20)

func _add_range_tiles(amount:int) -> void:
	while len(range_indicators) < amount:
		var new_indicator:RangeIndicator = RANGE_INDICATOR.instantiate()
		range_indicators.push_back(new_indicator)
		new_indicator.hide()
		add_child(new_indicator)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if !input_ok: return
		_use_ability()
	#TODO any other action cancels
	elif event.is_action_pressed("Right Click"):
		cancel_ability_targeting()

func _process(_delta: float) -> void:
	_get_ability_target()

func _hide_range_indicators() -> void:
	for ind:RangeIndicator in range_indicators:
		ind._reset_color()
		ind.hide()

func _visualize_tiles_in_range() -> void:
	var player_tile:Tile = tile_manager.char_tiles[player]
	var tiles_in_aoe:Array[Tile] = tile_manager.get_tiles_in_aoe(player_tile, selected_ability.get_range())
	tiles_in_aoe.erase(player_tile)
	_add_range_tiles(len(tiles_in_aoe))
	
	for i:int in len(tiles_in_aoe):
		var indicator:RangeIndicator = range_indicators[i]
		indicator.global_position = tiles_in_aoe[i].global_position
		if tiles_in_aoe[i].occupant:
			indicator.set_enemy_color()
		indicator.show()

func set_ability_to_target(new_ability:Ability) -> void:
	print_debug("set abi to target")
	if new_ability == null: return
	
	GlobalSignals.current_level.tile_manager.targeting_ability = true
	
	if player == null:
		player = GlobalSignals.player
		player_camera = player.player_camera

	selected_ability = new_ability
	_visualize_tiles_in_range()
	set_process(true)
	set_process_input(true)

func cancel_ability_targeting() -> void:
	print_debug("cancel abi targeting")
	_hide_range_indicators()
	set_process_input(false)
	set_process(false)
	_hide_aoe()
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_tile = null
	hovered_character = null
	selected_ability = null
	await get_tree().create_timer(.1).timeout
	GlobalSignals.current_level.tile_manager.targeting_ability = false

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

func _set_new_target_tile(new_target:Tile) -> void:
	if hovered_tile == new_target: return

	_hide_aoe()
	hovered_tile = new_target
	_show_aoe()

func _hide_aoe() -> void:
	for aoe_ind:Node3D in aoe_indicators:
		aoe_ind.visible = false

func _show_aoe() -> void:
	var tiles_in_aoe:Array[Tile] = tile_manager.get_tiles_in_aoe(hovered_tile, selected_ability.ability_aoe)
	while len(tiles_in_aoe) > len(aoe_indicators):
		var new_indicator:Node3D = AOE_INDICATOR.instantiate()
		new_indicator.visible = false
		add_child(new_indicator)
		aoe_indicators.push_back(new_indicator)

	for i:int in len(tiles_in_aoe):
		aoe_indicators[i].visible = true
		aoe_indicators[i].global_position = tiles_in_aoe[i].global_position

func _set_new_target_character(new_target:GameCharacter) -> void:
	if hovered_character == new_target: return
	
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_character = new_target
	GlobalSignals.show_outline_on_target.emit(hovered_character)

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
	if selected_ability.target_type == Ability.TARGET_TYPE.TILE:
		if hovered_tile != null:
			selected_ability.use_ability_on_target_tile(hovered_tile)
	elif selected_ability.target_type == Ability.TARGET_TYPE.GAME_CHARACTER:
		if hovered_character != null:
			selected_ability.use_ability_on_target_character(hovered_character)
	
	cancel_ability_targeting()
