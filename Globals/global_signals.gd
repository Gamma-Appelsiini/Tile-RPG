extends Node

signal change_level(new_level:Level)
signal show_container(new_container:LootContainer)
signal close_container(new_container:LootContainer)
signal start_dialogue(new_dialogue:DialogueResource)
signal dialogue_finished
signal enable_player_movement
signal disable_player_movement
signal play_audio(new_stream:AudioStream, pos:Vector3)

signal change_all_stats_visibility
