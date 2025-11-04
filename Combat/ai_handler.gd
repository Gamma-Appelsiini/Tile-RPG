extends Node
class_name AIHandler

enum INTELLIGENCE {DUMB, AVERAGE, SMART}

@export var combatant:GameCharacter = null
@export var combat_intelligence:INTELLIGENCE = INTELLIGENCE.AVERAGE


func take_turn() -> void:
	await get_tree().create_timer(0.3).timeout
	GlobalSignals.combat_manager.tile_manager._move_character_to_tile(combatant, GlobalSignals.combat_manager.tile_manager.tiles.values().pick_random())
	await GlobalSignals.combat_manager.tile_manager.character_moved
	await get_tree().create_timer(0.3).timeout
	combatant.end_turn.emit()
