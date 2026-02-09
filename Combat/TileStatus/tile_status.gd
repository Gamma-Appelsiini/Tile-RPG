extends Node3D
class_name TileStatus

@export var max_duration:int = 1

var current_duration:int = 0
var affected_tile:Tile = null

func set_on_tile(new_tile:Tile) -> void:
	self.global_position = new_tile.global_position
	affected_tile = new_tile
	_connect_signals()
	current_duration = max_duration
	
func _connect_signals() -> void:
	affected_tile.tile_entered.connect(_on_tile_entered)
	affected_tile.tile_left.connect(_on_tile_left)
	GlobalSignals.combat_end.connect(remove_tile_status)
	
	if !affected_tile.occupant: return
	
	affected_tile.occupant.start_turn.connect(_on_occupant_turn_start)
	affected_tile.occupant.end_turn.connect(_on_occupant_turn_end)
	
func _on_round_change() -> void:
	current_duration -= 1
	if current_duration == 0:
		remove_tile_status()
	
func remove_tile_status() -> void:
	queue_free()

#Override this
func _on_tile_entered(_entering_character:GameCharacter) -> void:
	_entering_character.start_turn.connect(_on_occupant_turn_start)
	_entering_character.end_turn.connect(_on_occupant_turn_end)

#Override this
func _on_tile_left(_leaving_character:GameCharacter) -> void:
	_leaving_character.start_turn.disconnect(_on_occupant_turn_start)
	_leaving_character.end_turn.disconnect(_on_occupant_turn_end)

#Override this
func _on_occupant_turn_start() -> void:
	pass
	
#Override this
func _on_occupant_turn_end() -> void:
	pass
