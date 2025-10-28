extends Node
class_name AIHandler

enum INTELLIGENCE {DUMB, AVERAGE, SMART}

@export var combatant:GameCharacter = null
@export var combat_intelligence:INTELLIGENCE = INTELLIGENCE.AVERAGE


func take_turn() -> void:
	await get_tree().create_timer(3).timeout
	combatant.end_turn.emit()
