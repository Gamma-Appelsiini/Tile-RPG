extends Node
class_name AIHandler

signal end_turn

enum INTELLIGENCE {DUMB, AVERAGE, SMART}

@export var combatant:GameCharacter = null
@export var combat_intelligence:INTELLIGENCE = INTELLIGENCE.AVERAGE
@export var offensive_abilities:Array[Ability] = []
@export var support_abilities:Array[Ability] = []
@export var movement_abilities:Array[Ability] = []

var friendlies:Array[GameCharacter] = []
var enemies:Array[GameCharacter] = []

var tile_manager:TileManager = null
var chosen_ability:Ability = null
var target_tile:Tile = null
var target_char:GameCharacter = null
var tiles_to_move_to:Array[Tile] = []

func _ready() -> void:
	end_turn.connect(_end_turn)
	
	for ability:Ability in offensive_abilities + support_abilities + movement_abilities:
		ability.ability_owner = combatant

func take_turn() -> void:
	tile_manager = GlobalSignals.current_level.tile_manager
	_set_teams()
	tiles_to_move_to = _get_reachable_tiles(_get_possible_tiles_to_move_to())
	
	var attacked:bool = await _try_to_attack()
	if !attacked:
		_move_to_character(target_char)
		await GlobalSignals.combat_manager.tile_manager.character_moved
		end_turn.emit()
	else: end_turn.emit()
	print("attacked: ", attacked)


func _try_to_attack() -> bool:
	print("1")
	if await _attack_lowest_health_enemy(): return true
	if await _attack_closest_enemy(): return true
	
	return false

func _get_any_usable_abilities() -> Array[Ability]:
	var all_abilities:Array[Ability] = offensive_abilities + support_abilities + movement_abilities
	all_abilities = all_abilities.duplicate().filter(func(abi:Ability): return abi.current_cooldown == 0)
	all_abilities = all_abilities.duplicate().filter(func(abi:Ability): return abi.ap_cost <= combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_AP])
	
	return all_abilities

func _end_turn() -> void:
	await get_tree().create_timer(0.3).timeout
	combatant.end_turn.emit()
	
func _dumb_choosing() -> void:
	#enum TARGET_TYPE {TILE, GAME_CHARACTER, NONE}
	#enum ABILITY_TAG {SINGLE_TARGET, AOE, MELEE, RANGED, SPELL, HIT, DOT, UNEVADEABLE, NO_RETALIATION, WEAPON}
	#enum CHARACTER_TYPE {ALLY, ENEMY, SELF}
	var all_abilities:Array[Ability] = offensive_abilities + support_abilities + movement_abilities
	all_abilities = all_abilities.duplicate().filter(func(abi:Ability): return abi.current_cooldown == 0)
	all_abilities = all_abilities.duplicate().filter(func(abi:Ability): return abi.ap_cost <= combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_AP])
	
	chosen_ability = all_abilities.pick_random()
	
	if offensive_abilities.has(chosen_ability):
		target_char = enemies[0]
		
	elif support_abilities.has(chosen_ability):
		if chosen_ability.usable_on_characters.has(Ability.CHARACTER_TYPE.SELF): target_char = combatant
		target_char = friendlies[0]

func _get_tile_closest_to_char(tiles:Array[Tile]) -> Tile:
	var closest_tile:Tile = tiles[0]
	var closest_distance:int = tile_manager.get_tile_distance(target_tile, closest_tile)
	
	for tile:Tile in tiles:
		var new_distance:int = tile_manager.get_tile_distance(target_tile, tile)
		if closest_distance > new_distance:
			closest_tile = tile
			closest_distance = new_distance
	
	return closest_tile

func _attack_closest_enemy() -> bool:
	enemies.sort_custom(compare_distance)
	target_char = enemies[0]
	target_tile = tile_manager.char_tiles[target_char]
	
	var usable_offensive_abilities:Array[Ability] = _filter_non_usable_abilities(offensive_abilities)
	for abi:Ability in usable_offensive_abilities:
		chosen_ability = abi
		if _get_tiles_where_ability_in_range(tiles_to_move_to) == []: usable_offensive_abilities.erase(abi)
		chosen_ability = null
		
	if usable_offensive_abilities.is_empty(): return false
		
	usable_offensive_abilities.sort_custom(compare_ability_power)
	if combat_intelligence == INTELLIGENCE.DUMB: chosen_ability = usable_offensive_abilities.pick_random()
	else: chosen_ability = usable_offensive_abilities[0]
	
	var tiles:Array[Tile] = _get_tiles_where_ability_in_range(tiles_to_move_to)
	_move_to_tile(_get_tile_closest_to_char(tiles))
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
	if chosen_ability.target_type == Ability.TARGET_TYPE.TILE: chosen_ability.use_ability_on_target_tile(target_tile)
	else: chosen_ability.use_ability_on_target_character(target_char)
	await chosen_ability.ability_finished
	
	return true

func _attack_lowest_health_enemy() -> bool:
	enemies.sort_custom(compare_health)
	target_char = enemies[0]
	target_tile = tile_manager.char_tiles[target_char]
	
	var usable_offensive_abilities:Array[Ability] = _filter_non_usable_abilities(offensive_abilities)
	for abi:Ability in usable_offensive_abilities:
		chosen_ability = abi
		if _get_tiles_where_ability_in_range(tiles_to_move_to) == []: usable_offensive_abilities.erase(abi)
		chosen_ability = null
		
	if usable_offensive_abilities.is_empty():
		print("No usable offe abilities")
		return false
		
	usable_offensive_abilities.sort_custom(compare_ability_power)
	if combat_intelligence == INTELLIGENCE.DUMB: chosen_ability = usable_offensive_abilities.pick_random()
	else: chosen_ability = usable_offensive_abilities[0]
	
	var tiles:Array[Tile] = _get_tiles_where_ability_in_range(tiles_to_move_to)
	_move_to_tile(tiles.pick_random())
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
	if chosen_ability.target_type == Ability.TARGET_TYPE.TILE: chosen_ability.use_ability_on_target_tile(target_tile)
	else: chosen_ability.use_ability_on_target_character(target_char)
	await chosen_ability.ability_finished
	
	return true

func _filter_non_usable_abilities(abilities:Array[Ability]) -> Array[Ability]:
	var usable_abilities:Array[Ability] = abilities.duplicate().filter(func(abi:Ability): return abi.current_cooldown == 0)
	usable_abilities = usable_abilities.duplicate().filter(func(abi:Ability): return abi.ap_cost <= combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_AP])
	
	return usable_abilities

func _is_ability_usable() -> bool:
	
	return true

func _choose_ability() -> void:
	
	_dumb_choosing()

func _move_randomly() -> void:
	tile_manager._move_character_to_tile(combatant, tile_manager.tiles.values().pick_random())
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
func _move_to_character(gchar:GameCharacter) -> void:
	tile_manager._move_character_to_tile(combatant, tile_manager.char_tiles[gchar])
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
func _move_to_tile(tile:Tile) -> void:
	tile_manager._move_character_to_tile(combatant, tile)

func _set_teams() -> void:
	if GlobalSignals.combat_manager.enemy_team.has(combatant):
		friendlies = GlobalSignals.combat_manager.enemy_team
		enemies = GlobalSignals.combat_manager.player_team
		
	else:
		friendlies = GlobalSignals.combat_manager.player_team
		enemies = GlobalSignals.combat_manager.enemy_team
		
	enemies.sort_custom(compare_distance)
	friendlies.erase(combatant)

func _get_tiles_where_ability_in_range(reachable_tiles:Array[Tile]) -> Array[Tile]:
	var in_range_tiles:Array[Tile] = []
	
	chosen_ability.target_tile = target_tile
	chosen_ability.target_char = target_tile.occupant
	for tile:Tile in reachable_tiles:
		if chosen_ability._is_in_range(tile): in_range_tiles.push_back(tile)
	
	chosen_ability.target_tile = null
	chosen_ability.target_char = null
	return in_range_tiles

func _get_possible_tiles_to_move_to() -> Array[Tile]:
	var possibles:Array[Tile] = []
	var movement_left:int = combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT]
	var combatant_tile:Tile = tile_manager.char_tiles[combatant]
	
	for tile:Tile in tile_manager.tiles.values():
		if tile.blocked: continue
		if tile_manager.get_tile_distance(combatant_tile, tile) <= movement_left:
			possibles.push_back(tile)
	
	return possibles

func _get_reachable_tiles(possible_tiles:Array[Tile]) -> Array[Tile]:
	var reachable_tiles:Array[Tile] = []
	var combatant_tile:Tile = tile_manager.char_tiles[combatant]
	
	for tile:Tile in possible_tiles:
		if tile_manager.get_shortest_path(combatant_tile,tile) == []: continue
		reachable_tiles.push_back(tile)
	
	return reachable_tiles

func compare_distance(a:GameCharacter, b:GameCharacter):
	var combatant_tile:Tile = tile_manager.char_tiles[combatant]
	return tile_manager.get_tile_distance(combatant_tile, tile_manager.char_tiles[a]) < tile_manager.get_tile_distance(combatant_tile, tile_manager.char_tiles[b])
	
func compare_health(a:GameCharacter, b:GameCharacter):
	return a.stat_handler.resources[Stats.ResourceStat.CURRENT_HP] < b.stat_handler.resources[Stats.ResourceStat.CURRENT_HP]
	
func compare_ability_power(a:Ability, b:Ability):
	return a.ability_power > b.ability_power
