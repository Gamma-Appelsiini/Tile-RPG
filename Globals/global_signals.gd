extends Node

var player:Player = null
var current_level:Level = null

signal change_level(new_level:Level)
signal show_container(new_container:LootContainer)
signal close_container(new_container:LootContainer)
signal start_dialogue(new_dialogue:DialogueResource)
signal dialogue_finished
signal enable_player_movement
signal disable_player_movement
signal play_audio(new_stream:AudioStream, pos:Vector3)
signal show_damage_number(amount:int, target_node:Node3D, crit:bool)
signal show_miss_text(miss_text:String, target_node:Node3D)

signal show_outline
signal hide_outline

signal change_all_stats_visibility
