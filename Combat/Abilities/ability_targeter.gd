extends Node
class_name AbilityTargeter

const AOE_INDICATOR:PackedScene = preload("uid://mn3gwrbcqycm")
const RANGE_INDICATOR := preload("uid://ff1heogqgu75")

var player:Player = null
var player_camera:Camera3D = null
var tile_manager:TileManager = null

var selected_ability:Ability = null
var selected_slot:AbilitySlot = null
var hovered_character:GameCharacter = null
var hovered_tile:Tile = null
var aoe_indicators:Array[Node3D] = []
var input_ok:bool = false
var range_indicators:Array[RangeIndicator] = []
var hidden_indicators:Array[RangeIndicator] = []
var range_mesh:MeshInstance3D = null

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	_add_range_tiles(20)

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
		if !input_ok: return
		_use_ability()
	#Any other action other than camera movement in input map cancels
	elif _is_input_non_cancelling(event):
		return
	elif event.is_pressed() and not event.is_echo():
		cancel_ability_targeting()

func _is_input_non_cancelling(event: InputEvent) -> bool:
	if event.is_action_pressed("roll_up") or event.is_action_pressed("roll_down") or event.is_action_pressed("Backward") or event.is_action_pressed("Forward") or event.is_action_pressed("Left") or event.is_action_pressed("Right") or event.is_action_pressed("Rotate_Cam_L") or event.is_action_pressed("Rotate_Cam_R"):
		return true
	
	const ABI_INPUTS:Array[String] = ["ability 0", "ability 1", "ability 2", "ability 3", "ability 4", "ability 5", "ability 6", "ability 7", "ability 8", "ability 9", ]
	for input_name:String in ABI_INPUTS:
		if event.is_action_pressed(input_name): return true
	
	return false

func _process(_delta: float) -> void:
	_get_ability_target()

func _hide_range_indicators() -> void:
	for ind:RangeIndicator in range_indicators:
		ind._reset_color()
		ind.hide()

func _visualize_tiles_in_range() -> void:
	var player_tile:Tile = tile_manager.char_tiles[player]
	var tiles_in_range:Array[Tile] = tile_manager.get_tiles_in_range(player_tile, selected_ability.get_range())
	_add_range_tiles(len(tiles_in_range))
	
	for i:int in len(tiles_in_range):
		var indicator:RangeIndicator = range_indicators[i]
		indicator.global_position = tiles_in_range[i].global_position
		if tiles_in_range[i].occupant:
			indicator.set_enemy_color()
		indicator.show()

func set_ability_to_target(new_slot:AbilitySlot) -> void:
	var new_ability:Ability = new_slot.ability_in_slot
	
	if new_ability == null:
		print("new abi null")
		cancel_ability_targeting()
		return
	
	if selected_ability == new_ability or selected_slot == new_slot: 
		print("same abi, cancelling target")
		cancel_ability_targeting()
		return
	elif selected_ability: cancel_ability_targeting()
	
	selected_ability = new_ability
	GlobalSignals.current_level.tile_manager.targeting_ability = true
	selected_slot = new_slot
	selected_slot.glow_rect.show()
	
	if player == null:
		player = GlobalSignals.player
		player_camera = player.player_camera

	_start_targeting_animation()
	_visualize_tiles_in_range()
	set_process(true)
	set_process_input(true)

func cancel_ability_targeting() -> void:
	if selected_ability == null: return
	
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
	#await get_tree().create_timer(.01).timeout
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
