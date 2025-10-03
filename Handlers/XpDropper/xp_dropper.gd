extends Node
class_name XpDropper

@export var xp_amount:int = 1
@export var dropping_character:GameCharacter = null

const ORB_SCENE:PackedScene = preload("res://Tile-RPG/Handlers/XpDropper/xp_orb.tscn")
const EXPLOSION_SPEED:float = 12

var globes_amounts:Dictionary[int,int] = {}

func _ready() -> void:
	_set_dropper()
	dropping_character.died.connect(_drop_xp)

func _drop_xp() -> void:
	_divide()
	_create_globes()

func _create_globes() -> void:
	for xp_orb in globes_amounts:
		var i = globes_amounts[xp_orb]
		while i > 0:
			_create_globe(xp_orb)
			i -= 1

func _create_globe(type:int) -> void:
	var new_orb:XpOrb = ORB_SCENE.instantiate()
	add_child(new_orb)
	var player:Player = null
	new_orb.set_params(type,player)
	_spawn_offset(new_orb)
	apply_force(new_orb)

func _set_dropper() -> void:
	if dropping_character != null: return
	if get_parent() is GameCharacter:
		dropping_character = get_parent() as GameCharacter

func _divide()-> void:
	globes_amounts[50] = xp_amount / 50
	var remaining:int = xp_amount % 50
	
	globes_amounts[25] = remaining / 25
	remaining = remaining % 25
	
	globes_amounts[10] = remaining / 10
	remaining = remaining % 10
	
	globes_amounts[1] = remaining


func _spawn_offset(orb:XpOrb)-> void:
	orb.global_position += Vector3(randf_range(-0.2,0.2),randf_range(0.05,0.2),randf_range(-0.2,0.2))

func apply_force(orb:XpOrb)-> void:
	var vel:Vector3 = (orb.global_transform.origin - self.global_transform.origin) * EXPLOSION_SPEED
	orb.linear_velocity = vel
