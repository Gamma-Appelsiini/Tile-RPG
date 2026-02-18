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
@export var character_texture:CompressedTexture2D = null
@export var main_hand_node: Node3D = null
@export var off_hand_node: Node3D = null
@export var shield_node: Node3D = null
@export var head_node: Node3D = null

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
const DEATH_ANIMATIONS:Array[CharAnimation] = [CharAnimation.DIE_1,CharAnimation.DIE_2]
const CHAR_DISSOLVE_MATERIAL := preload("uid://cikrwp1quigsr")
const DISSOLVE_TIME:float = 1.0
const DELAYS:Dictionary[CharAnimation,float] = {
	CharAnimation.DRAW_WEAPON: 0.35,
	}
const CASTING_EFFECT := preload("uid://bij1r8xadcvhl")
const GROUND_CASTING_EFFECT := preload("uid://2u1utrq13bbp")

var casting_hand_effect:Effect = null
var casting_ground_effect:Effect = null


func die() -> void:
	play_animation(DEATH_ANIMATIONS.pick_random(), false)
	if game_character is Player:
		_player_death()
		return
	
	await animation_player.animation_finished
	
	var dissolve_material:ShaderMaterial = CHAR_DISSOLVE_MATERIAL.duplicate()
	dissolve_material.set_shader_parameter("baseColorTexture", character_texture)
	character_mesh.material_override = dissolve_material
	
	var tween:Tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolveSlider", 1, DISSOLVE_TIME)
	
	await tween.finished
	game_character.queue_free()

func start_casting_effects() -> void:
	casting_hand_effect.play_effect()
	casting_ground_effect.global_position = character_mesh.global_position
	casting_ground_effect.play_effect()

func stop_casting_effects() -> void:
	casting_hand_effect.end_effect()
	casting_ground_effect.end_effect()

#TODO
func _player_death() -> void:
	pass

func _ready() -> void:
	if get_parent_node_3d() is GameCharacter: game_character = get_parent_node_3d()
	play_idle_animation()
	
	casting_hand_effect = CASTING_EFFECT.instantiate()
	casting_ground_effect = GROUND_CASTING_EFFECT.instantiate()
	
	off_hand_node.add_child(casting_hand_effect)
	add_child(casting_ground_effect)

func play_animation(animation:CharAnimation, return_to_idle:bool = true, play_backwards:bool = false) -> void:
	if game_character.character_state == game_character.CharacterState.STUNNED or game_character.character_state == game_character.CharacterState.FROZEN: return
	
	if !ANIMATION_ENUM_TO_STRING.has(animation):
		print_debug("No animation ", animation, " in animation dict")
		return
	
	if play_backwards: animation_player.play_backwards(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[animation], BLEND_TIME)
	else: animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[animation], BLEND_TIME)
	
	if !return_to_idle: return
	
	await animation_player.animation_finished
	play_idle_animation() 

func play_idle_animation() -> void:
	if !game_character:
		print_debug("No game character. Mesh; ", character_mesh)
		return
	
	if game_character.character_state == game_character.CharacterState.OUT_OF_COMBAT:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.IDLE], BLEND_TIME)
	elif game_character.character_state == game_character.CharacterState.IN_COMBAT:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.COMBAT_IDLE_1], BLEND_TIME)
	elif game_character.character_state == game_character.CharacterState.STUNNED:
		animation_player.play(PLAYER_PREFIX + ANIMATION_ENUM_TO_STRING[CharAnimation.STUNNED], BLEND_TIME)
