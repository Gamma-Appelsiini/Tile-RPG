extends Node
class_name XpDropper

@export var xp_amount:int = 1
@export var dropping_character:GameCharacter = null

const ORB_SCENE:PackedScene = preload("res://Tile-RPG/Handlers/XpDropper/xp_orb.tscn")
const EXPLOSION_SPEED:float = 6

var globes_amounts:Dictionary[int,int] = {}

func _ready() -> void:
	_set_dropper()
	dropping_character.died.connect(_drop_xp)

func _drop_xp(dropper:GameCharacter) -> void:
	dropping_character = dropper
	_divide()
	_create_globes()

func _create_globes() -> void:
	for xp_orb in globes_amounts:
		var i:int = globes_amounts[xp_orb]
		while i > 0:
			_create_globe(xp_orb)
			i -= 1

func _create_globe(type:int) -> void:
	var new_orb:XpOrb = ORB_SCENE.instantiate()
	dropping_character.add_child(new_orb)
	
	var player:Player = GlobalSignals.player
	new_orb.set_params(type,player)
	_spawn_offset(new_orb)
	apply_force(new_orb)

func _set_dropper() -> void:
	if dropping_character != null: return
	if get_parent() is GameCharacter:
		dropping_character = get_parent() as GameCharacter

func _divide()-> void:
	globes_amounts[50] = int(xp_amount / 50.0)
	var remaining:int = xp_amount % 50
	
	globes_amounts[25] = int(remaining / 25.0)
	remaining = remaining % 25
	
	globes_amounts[10] = int(remaining / 10.0)
	remaining = remaining % 10
	
	globes_amounts[1] = remaining

func _spawn_offset(orb:XpOrb)-> void:
	orb.global_position += Vector3(0,1,0)
	orb.global_position += Vector3(randf_range(-0.2,0.2),randf_range(0.05,0.2),randf_range(-0.2,0.2))

func apply_force(orb:XpOrb)-> void:
	var vel:Vector3 = (orb.global_transform.origin - dropping_character.global_transform.origin) * EXPLOSION_SPEED
	orb.linear_velocity = vel
