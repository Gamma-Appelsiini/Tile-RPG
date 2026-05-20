extends Node
class_name Tile

signal tile_entered(enterer:GameCharacter)
signal tile_left(leaver:GameCharacter)

var tile_manager:TileManager = null
var neighbor_tiles:Array[Tile] = []
var diagonal_tiles:Array[Tile] = []
var occupant:GameCharacter = null
var blockers:Array[Node3D] = []

@export var surface_normal: Vector3 = Vector3.UP
@export var global_position:Vector3 = Vector3.ZERO

var visited:bool = false
var came_from:Tile = null
var blocked:bool = false
var entered:bool = false

func reset_tile() -> void:
	visited = false
	came_from = null

func add_blocker(new_blocker:Node3D) -> void:
	blockers.push_back(new_blocker)
	blocked = true
	
func remove_blocker(new_blocker:Node3D) -> void:
	blockers.erase(new_blocker)
	if len(blockers) == 0: blocked = false
