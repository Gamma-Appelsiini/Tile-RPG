extends Node
class_name Tile


var tile_manager:TileManager = null
var neighbor_tiles:Array[Tile] = []
var occupant:GameCharacter = null
@export var global_position:Vector3 = Vector3.ZERO

var visited:bool = false
var came_from:Tile = null

var blocked:bool = false
var entered:bool = false

func reset_tile() -> void:
	visited = false
	came_from = null
