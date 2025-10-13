extends Node
class_name AbilityTargeter

var player:Player = null
var player_camera:Camera3D = null
var tile_manager:TileManager = null

var selected_ability:Ability = null
var hovered_character:GameCharacter = null
var hovered_tile:Tile = null

func _ready() -> void:
	set_process(false)
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_use_ability()
	elif event.is_action_pressed("Right Click"):
		cancel_ability_targeting()

func _process(_delta: float) -> void:
	_get_ability_target()

func set_ability_to_target(new_ability:Ability) -> void:
	print("set abi to target")
	if new_ability == null: return
	if player == null:
		player = GlobalSignals.player
		player_camera = player.player_camera

	selected_ability = new_ability
	set_process(true)
	set_process_input(true)

func cancel_ability_targeting() -> void:
	print("cancel abi targeting")
	set_process_input(false)
	set_process(false)
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_tile = null
	hovered_character = null
	selected_ability = null

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

	#TODO hide hovered tile
	hovered_tile = new_target
	#TODO show new tile + aoe

func _set_new_target_character(new_target:GameCharacter) -> void:
	if hovered_character == new_target: return
	
	GlobalSignals.hide_outline_on_target.emit(hovered_character)
	hovered_character = new_target
	GlobalSignals.show_outline_on_target.emit(hovered_character)

func _shoot_ray() -> Dictionary:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = player_camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + player_camera.project_ray_normal(mouse_pos) * 2000.0
	
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
