extends Node
class_name AIHandler

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

func take_turn() -> void:
	tile_manager = GlobalSignals.current_level.tile_manager
	_set_teams()
	
	#await get_tree().create_timer(0.3).timeout
	#GlobalSignals.combat_manager.tile_manager._move_character_to_tile(combatant, GlobalSignals.combat_manager.tile_manager.tiles.values().pick_random())
	#await GlobalSignals.combat_manager.tile_manager.character_moved
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
	await GlobalSignals.combat_manager.tile_manager.character_moved

func _set_teams() -> void:
	if GlobalSignals.combat_manager.enemy_team.has(combatant):
		friendlies = GlobalSignals.combat_manager.enemy_team
		enemies = GlobalSignals.combat_manager.player_team
		
	else:
		friendlies = GlobalSignals.combat_manager.player_team
		enemies = GlobalSignals.combat_manager.enemy_team
		
	enemies.sort_custom(compare_distance)
	friendlies.erase(self)

func _get_tiles_where_ability_in_range(reachable_tiles:Array[Tile]) -> Array[Tile]:
	var in_range_tiles:Array[Tile] = []
	
	chosen_ability.target_tile = target_tile
	for tile:Tile in reachable_tiles:
		if !chosen_ability._is_in_range(): continue
		in_range_tiles.push_back(tile)
	
	chosen_ability.target_tile = null
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
