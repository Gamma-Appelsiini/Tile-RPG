extends Node3D
class_name CharacterModelHandler

enum CharAnimation {
	ATTACK_1H, ATTACK_2H, ATTACK_BOW, ATTACK_PUNCH, BLOCK, CAST_SPELL, CASTING, COMBAT_IDLE_1,
	DIE_1, DIE_2, DODGE, DRAW_WEAPON, DRINK_POTION, FROZEN, IDLE, IDLE_ACTION_2, IDLE_ACTION_3,
	IDLE_ACTION_4, INTERACT, MINE, OPEN_DOOR_1, PICKUP, RUN, STUNNED, TAKE_DAMAGE_FROM_BACK,
	TAKE_DAMAGE_FROM_FRONT, TAKE_DAMAGE_FROM_LEFT, TAKE_DAMAGE_FROM_RIGHT, NULL}

@export var character_mesh:MeshInstance3D = null
@export var animation_player: AnimationPlayer = null
@export var game_character:GameCharacter = null
@export var outline_handler: OutlineHandler = null

const PLAYER_PREFIX:String = "animations/"
const ANIMATION_ENUM_TO_STRING:Dictionary[CharAnimation, String] = {
	CharAnimation.ATTACK_1H: "attack_1h",
	CharAnimation.ATTACK_2H: "attack_2h",
	CharAnimation.ATTACK_BOW: "attack_bow",
	CharAnimation.ATTACK_PUNCH: "attack_punch",
	CharAnimation.BLOCK: "block",
	CharAnimation.CAST_SPELL: "cast_spell",
	CharAnimation.CASTING: "casting",
	CharAnimation.COMBAT_IDLE_1: "combat_idle1",
	CharAnimation.DIE_1: "die1",
	CharAnimation.DIE_2: "die2",
	CharAnimation.DODGE: "dodge",
	CharAnimation.DRAW_WEAPON: "draw_weapon",
	CharAnimation.DRINK_POTION: "drink_potion",
	CharAnimation.FROZEN: "frozen",
	CharAnimation.IDLE: "idle",
	CharAnimation.IDLE_ACTION_2: "idle_action2",
	CharAnimation.IDLE_ACTION_3: "idle_action3",
	CharAnimation.IDLE_ACTION_4: "idle_action4",
	CharAnimation.INTERACT: "interact",
	CharAnimation.MINE: "mine",
	CharAnimation.OPEN_DOOR_1: "open_door1",
	CharAnimation.PICKUP: "pickup2",
	CharAnimation.RUN: "run",
	CharAnimation.STUNNED: "stunned",
	CharAnimation.TAKE_DAMAGE_FROM_BACK: "take_damage_from_back",
	CharAnimation.TAKE_DAMAGE_FROM_FRONT: "take_damage_from_front",
	CharAnimation.TAKE_DAMAGE_FROM_LEFT: "take_damage_from_left",
	CharAnimation.TAKE_DAMAGE_FROM_RIGHT: "take_damage_from_right",
}
const BLEND_TIME:float = 0.1

func _ready() -> void:
	if get_parent_node_3d() is GameCharacter: game_character = get_parent_node_3d()
	_play_idle_animation()

func play_animation(animation:CharAnimation, return_to_idle:bool = true) -> void:
	if game_character.character_state == game_character.CharacterState.STUNNED or game_character.character_state == game_character.CharacterState.FROZEN: return
	
	if !ANIMATION_ENUM_TO_STRING.has(animation):
		print_debug("No animation ", animation, " in animation dict")
		return
	
	animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[animation], BLEND_TIME)
	
	if !return_to_idle: return
	
	await animation_player.animation_finished
	_play_idle_animation() 


func _play_idle_animation() -> void:
	if game_character.character_state == game_character.CharacterState.OUT_OF_COMBAT:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.IDLE], BLEND_TIME)
	elif game_character.character_state == game_character.CharacterState.IN_COMBAT:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.COMBAT_IDLE_1], BLEND_TIME)
	elif game_character.character_state == game_character.CharacterState.STUNNED:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.STUNNED], BLEND_TIME)
