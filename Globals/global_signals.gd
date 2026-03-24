extends Node

var player:Player = null
var current_level:Level = null
var combat_manager:CombatManager = null
var quest_handler:QuestHandler = null
var ui_handler:UIHandler = null

signal change_level(new_level:Level)
signal show_container(new_container:LootContainer)
signal close_container(new_container:LootContainer)
signal start_dialogue(new_dialogue:DialogueResource)
signal dialogue_finished
signal enable_player_movement
signal disable_player_movement

signal play_audio(new_stream:AudioStream, pos:Vector3)
signal change_volume(audio_type:AudioManager.AUDIO_TYPE, amount:float)

signal show_damage_number(amount:int, target_node:Node3D, crit:bool)
signal show_miss_text(miss_text:String, target_node:Node3D)
signal show_floating_text(text:String, target_node:Node3D, font_color:Color)

signal show_info_bar
signal hide_info_bar
signal show_outline
signal show_outline_on_target(target:Node3D)
signal hide_outline
signal hide_outline_on_target(target:Node3D)

signal change_all_stats_visibility

signal combat_start
signal combat_end
