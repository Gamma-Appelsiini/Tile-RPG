extends Node
class_name AIHandler

enum INTELLIGENCE {DUMB, AVERAGE, SMART}

@export var combatant:GameCharacter = null
@export var combat_intelligence:INTELLIGENCE = INTELLIGENCE.AVERAGE

var tile_manager:TileManager = null

func take_turn() -> void:
	tile_manager = GlobalSignals.current_level.tile_manager
	
	#await get_tree().create_timer(0.3).timeout
	#GlobalSignals.combat_manager.tile_manager._move_character_to_tile(combatant, GlobalSignals.combat_manager.tile_manager.tiles.values().pick_random())
	#await GlobalSignals.combat_manager.tile_manager.character_moved
	await get_tree().create_timer(0.3).timeout
	combatant.end_turn.emit()

func _get_possible_tiles_to_move_to() -> Array[Tile]:
	var possibles:Array[Tile] = []
	var movement_left:int = combatant.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT]
	var combatant_tile:Tile = tile_manager.char_tiles[combatant]
	
	for tile:Tile in tile_manager.tiles.values():
		if tile_manager.get_tile_distance(combatant_tile, tile) <= movement_left:
			possibles.push_back(tile)
	
	
	return possibles
