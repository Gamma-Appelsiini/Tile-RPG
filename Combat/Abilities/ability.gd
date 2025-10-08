extends Node
class_name Ability

signal ability_finished

enum TARGET_TYPE {TILE, GAME_CHARACTER, NONE}
enum ABILITY_TAG {SINGLE_TARGET, AOE}
enum CHARACTER_TYPE {ALLY, ENEMY, SELF}
enum ANIMATION_TYPE {MELEE, SPELL, RANGED}

@export var animation_type:ANIMATION_TYPE = ANIMATION_TYPE.MELEE
@export var target_type:TARGET_TYPE = TARGET_TYPE.GAME_CHARACTER
@export var usable_on_characters:Array[CHARACTER_TYPE] = []
@export var ability_icon: Texture = null
@export var ability_name:String = "Default Ability Name"
@export var ability_cooldown: int = 0
@export var ap_cost: int = 1
@export var spirit_cost: int = 0
@export var ability_range: int = 1

var ability_owner:GameCharacter = null
var current_cooldown:int = 0
var ability_description:String = "Default Ability Description"
var target_char:GameCharacter = null
var target_tile:Tile = null

#Override
func _set_description() -> void:
	pass

#Override
func use_ability_on_target_character(target:GameCharacter) -> void:
	print(target.name)
	pass

#Override
func use_ability_on_target_tile(target:Tile) -> void:
	print(target.name)
	pass

#TODO
func _set_weapon_damage(attack:Attack) -> Attack:
	return attack

func _is_in_range() -> bool:
	var tile_manager:TileManager = null
	var ability_user_tile:Tile = tile_manager.char_tiles[ability_owner]
	var distance:int = -1
	
	if target_type == TARGET_TYPE.NONE: return true
	elif target_type == TARGET_TYPE.TILE:
		distance = tile_manager.get_distance_to_tile(ability_user_tile, target_tile)
	else:
		var ability_target_tile:Tile = tile_manager.char_tiles[target_char]
		distance = tile_manager.get_distance_to_tile(ability_user_tile, ability_target_tile)
	
	if distance == -1 or distance > ability_range:
		print("Ability not in range")
		return false
	
	return true
