extends Node
class_name AIHandler

signal end_turn

enum INTELLIGENCE {DUMB, AVERAGE, SMART}
enum COMBAT_TYPE {RANGED, MELEE, SUPPORT}

@export var combatant:GameCharacter = null
@export var combat_intelligence:INTELLIGENCE = INTELLIGENCE.AVERAGE
@export var combat_type:COMBAT_TYPE = COMBAT_TYPE.MELEE
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
	
	if _is_target_too_far(enemies, offensive_abilities): await _use_movement_ability()
	
	if _is_damaged_friendlies():
		var healed:bool = await _heal_lowest_health_ally()
	
	tiles_to_move_to = _get_reachable_tiles(_get_possible_tiles_to_move_to())
	
	var attacked:bool = await _try_to_attack()
	if !attacked:
		_move_to_character(target_char)
		await GlobalSignals.combat_manager.tile_manager.character_moved
	
	await _handle_turn_end_movement()
	
	end_turn.emit()

func _take_dumb_turn() -> void:
	var actions:Array[Callable] = [_try_to_attack, _buff_friendly, _use_defensive_ability, _heal_lowest_health_ally]
	
	await _handle_turn_end_movement()

func _use_movement_ability() -> bool:
	var targets:Array[GameCharacter] = [combatant]
	return await _use_ability_with_tag(Ability.ABILITY_TAG.MOVEMENT, targets, movement_abilities)

func _is_target_too_far(targets:Array[GameCharacter], abilities:Array[Ability]) -> bool:
	var usable_abilities:Array[Ability] = _filter_non_usable_abilities(abilities)
	usable_abilities.sort_custom(compare_ability_range)
	if usable_abilities.is_empty(): return true
	
	chosen_ability = usable_abilities[0]
	targets.sort_custom(compare_distance)
	target_char = targets[0]
	target_tile = tile_manager.char_tiles[target_char]
	
	if _get_tiles_where_ability_in_range(tiles_to_move_to) == []: return true
	
	return false

func _use_defensive_ability() -> bool:
	var targets:Array[GameCharacter] = friendlies.duplicate()
	targets.push_back(combatant)
	return await _use_ability_with_tag(Ability.ABILITY_TAG.DEFENSIVE, targets, support_abilities)

func _use_ability_with_tag(tag:Ability.ABILITY_TAG, targets:Array[GameCharacter], abilities:Array[Ability]) -> bool:
	var usable_abilities:Array[Ability] = _filter_non_usable_abilities(abilities)
	usable_abilities = usable_abilities.filter(func(abi:Ability): return abi.ability_tags.has(tag))
	if usable_abilities.is_empty(): return false
	
	var ability_targets:Array[GameCharacter] = targets.duplicate()
	
	ability_targets.sort_custom(compare_character_power)
	var possible_abilities:Array[Ability] = []
	
	for new_target:GameCharacter in ability_targets:
		possible_abilities = usable_abilities.duplicate()
		target_char = new_target
		target_tile = tile_manager.char_tiles[target_char]
	
		if target_char == combatant:
			possible_abilities.filter(func(abi:Ability): return abi.usable_on_characters.has(Ability.CHARACTER_TYPE.SELF))
			if possible_abilities.is_empty(): continue
			else: break
	
		for abi:Ability in usable_abilities:
			chosen_ability = abi
			if _get_tiles_where_ability_in_range(tiles_to_move_to) == []: possible_abilities.erase(abi)
			chosen_ability = null
			
		if !possible_abilities.is_empty(): break
	
	if possible_abilities.is_empty(): return false
	_use_the_best_ability(possible_abilities)
	await chosen_ability.ability_finished
	
	return true

func _handle_turn_end_movement() -> void:
	if combatant.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_MOVEMENT) == 0: return
	
	if combat_intelligence == INTELLIGENCE.SMART:
		if combatant.status_handler.has_status("Bleed"): return
		
	if combat_intelligence != INTELLIGENCE.DUMB:
		if combatant.stat_handler.is_on_low_health():
			var moved:bool = await _move_to_support_ally()
			if moved: return
	
	if combat_type == COMBAT_TYPE.RANGED:
		await _run_away_from_enemies()
	elif combat_type == COMBAT_TYPE.MELEE:
		enemies.sort_custom(compare_distance)
		var closest_enemy:GameCharacter = enemies[0]
		await _move_to_character(closest_enemy)
	elif combat_type == COMBAT_TYPE.SUPPORT:
		if friendlies.is_empty():
			await _move_randomly()
			return
		friendlies.sort_custom(compare_distance)
		var closest_ally:GameCharacter = friendlies[0]
		await _move_to_character(closest_ally)

func _move_to_support_ally() -> bool:
	var support_allies:Array[GameCharacter] = []
	for gchar:GameCharacter in friendlies:
		if gchar.ai_handler.combat_type == COMBAT_TYPE.SUPPORT: support_allies.push_back(gchar)
		
	if support_allies.is_empty(): return false
	support_allies.sort_custom(compare_distance)
	var target_to_move_to:GameCharacter = support_allies[0]
	
	await _move_to_character(target_to_move_to)
	return true

func _buff_friendly() -> bool:
	var targets:Array[GameCharacter] = friendlies.duplicate()
	targets.push_back(combatant)
	return await _use_ability_with_tag(Ability.ABILITY_TAG.BUFF, targets, support_abilities)

func _run_away_from_enemies() -> bool:
	var furthest_tile:Tile = _get_furthest_tile_from_enemies()
	if furthest_tile == null: return false
	
	_move_to_tile(furthest_tile)
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
	return true

func _get_furthest_tile_from_enemies() -> Tile:
	tiles_to_move_to = _get_reachable_tiles(_get_possible_tiles_to_move_to())
	if tiles_to_move_to.is_empty(): return null
	
	var enemy_tiles:Array[Tile] = []
	for enemy:GameCharacter in enemies:
		enemy_tiles.push_back(tile_manager.char_tiles[enemy])

	var furthest_tile:Tile = tiles_to_move_to[0]
	var max_total_distance:int = -1
	
	for tile:Tile in tiles_to_move_to:
		var total_distance:int = 0
		for enemy_tile:Tile in enemy_tiles:
			total_distance += tile_manager.get_distance_to_tile(tile, enemy_tile)
		
		if total_distance > max_total_distance:
			max_total_distance = total_distance
			furthest_tile = tile
	
	return furthest_tile

func _try_to_attack() -> bool:
	if await _attack_lowest_health_enemy(): return true
	if await _attack_closest_enemy(): return true
	
	return false

func _is_damaged_friendlies() -> bool:
	var all_friendlies:Array[GameCharacter] = friendlies.duplicate()
	all_friendlies.push_back(combatant)
	all_friendlies = all_friendlies.filter(func(gc:GameCharacter): return gc.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP) < gc.stat_handler.get_stat_amount(Stats.ResourceStat.MAX_HP))
	
	if all_friendlies.is_empty(): return false
	else: return true

func _heal_lowest_health_ally() -> bool:
	var targets:Array[GameCharacter] = friendlies.duplicate()
	targets.push_back(combatant)
	targets.sort_custom(compare_health)
	targets.filter(func(gc:GameCharacter): return gc.stat_handler.is_not_on_full_health())
	
	if targets.is_empty(): return false
	
	return await _use_ability_with_tag(Ability.ABILITY_TAG.HEAL, targets, support_abilities)

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
		
	if usable_offensive_abilities.is_empty():
		return false
		
	await _use_the_best_ability(usable_offensive_abilities)
	
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
		return false
		
	await _use_the_best_ability(usable_offensive_abilities)
	
	return true

func _use_the_best_ability(usable_abilities:Array[Ability]) -> void:
	usable_abilities.sort_custom(compare_ability_power)
	if combat_intelligence == INTELLIGENCE.DUMB: chosen_ability = usable_abilities.pick_random()
	else: chosen_ability = usable_abilities[0]
	
	var tiles:Array[Tile] = _get_tiles_where_ability_in_range(tiles_to_move_to)
	if target_char != combatant:
		_move_to_tile(tiles.pick_random())
		await GlobalSignals.combat_manager.tile_manager.character_moved
	
	if chosen_ability.target_type == Ability.TARGET_TYPE.TILE: chosen_ability.use_ability_on_target_tile(target_tile)
	else: chosen_ability.use_ability_on_target_character(target_char)
	
	await chosen_ability.ability_finished

func _filter_non_usable_abilities(abilities:Array[Ability]) -> Array[Ability]:
	var usable_abilities:Array[Ability] = abilities.duplicate().filter(func(abi:Ability): return abi.current_cooldown == 0)
	usable_abilities = usable_abilities.duplicate().filter(func(abi:Ability): return abi.ap_cost <= combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_AP])
	
	return usable_abilities

func _is_ability_usable() -> bool:
	
	return true

func _choose_ability() -> void:
	
	_dumb_choosing()

func _move_randomly() -> void:
	tile_manager._move_character_to_tile(combatant, tile_manager.tiles.values().pick_random(), true)
	await GlobalSignals.combat_manager.tile_manager.character_moved
	
func _move_to_character(gchar:GameCharacter) -> void:
	tile_manager.move_character_to_character(combatant, gchar)
	await tile_manager.character_moved
	
func _move_to_tile(tile:Tile) -> void:
	tile_manager._move_character_to_tile(combatant, tile)
	await tile_manager.character_moved

func _set_teams() -> void:
	if GlobalSignals.combat_manager.enemy_team.has(combatant):
		friendlies = GlobalSignals.combat_manager.enemy_team.duplicate()
		enemies = GlobalSignals.combat_manager.player_team.duplicate()
		
	else:
		friendlies = GlobalSignals.combat_manager.player_team.duplicate()
		enemies = GlobalSignals.combat_manager.enemy_team.duplicate()
		
	friendlies.erase(combatant)

func _get_tiles_where_ability_in_range(reachable_tiles:Array[Tile]) -> Array[Tile]:
	tiles_to_move_to = _get_reachable_tiles(_get_possible_tiles_to_move_to())
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
	var move_amount:int = combatant.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_MOVEMENT)
	
	for tile:Tile in possible_tiles:
		var path:Array[Tile] = tile_manager.get_shortest_path(combatant_tile,tile)
		if path == []: continue
		elif len(path) > move_amount: continue
		reachable_tiles.push_back(tile)
	
	return reachable_tiles

func compare_distance(a:GameCharacter, b:GameCharacter):
	var combatant_tile:Tile = tile_manager.char_tiles[combatant]
	return tile_manager.get_tile_distance(combatant_tile, tile_manager.char_tiles[a]) < tile_manager.get_tile_distance(combatant_tile, tile_manager.char_tiles[b])
	
func compare_health(a:GameCharacter, b:GameCharacter):
	return a.stat_handler.resources[Stats.ResourceStat.CURRENT_HP] < b.stat_handler.resources[Stats.ResourceStat.CURRENT_HP]

func compare_character_power(a:GameCharacter, b:GameCharacter):
	return a.character_power < b.character_power

func compare_ability_power(a:Ability, b:Ability):
	return a.ability_power > b.ability_power

func compare_ability_range(a:Ability, b:Ability):
	return a.get_range() > b.get_range()
