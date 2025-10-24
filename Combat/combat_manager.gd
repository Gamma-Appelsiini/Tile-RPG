extends Node
class_name CombatManager

signal round_changed(number:int)

@export var combat_start_music:AudioStream = null
@export var combat_end_music:AudioStream = null
@export var player_turn_sound:AudioStream = null
@export var turn_change_sound:AudioStream = null
@export var round_change_sound:AudioStream = null

var chars_in_combat:Array[GameCharacter] = []
var round_order:Array[GameCharacter] = []
var player_team:Array[GameCharacter] = []
var enemy_team:Array[GameCharacter] = []
var player:Player = null

var round_count:int = 0
var char_to_act:GameCharacter = null

func _start_combat(new_enemies:Array[GameCharacter]) -> void:
	_reset()
	GlobalSignals.play_audio.emit(combat_start_music, AudioManager.AUDIO_TYPE.UI)
	
	player = GlobalSignals.player
	#TODO Add player team
	player_team.push_back(player)
	
	enemy_team = new_enemies
	chars_in_combat = player_team + enemy_team
	for game_char:GameCharacter in chars_in_combat:
		game_char.died.connect(_char_died)
	
	_next_round()
	
func _next_round() -> void:
	round_count += 1
	round_order = chars_in_combat.duplicate()
	GlobalSignals.play_audio.emit(round_change_sound, AudioManager.AUDIO_TYPE.UI)
	round_changed.emit(round_count)
	_next_turn()

func _next_turn() -> void:
	if len(round_order) == 0:
		_next_round()
		return
	
	round_order.sort_custom(_compare_initiative)
	char_to_act = round_order[0]
	char_to_act.end_turn.connect(_next_turn)
	
	if char_to_act is Player:
		#TODO
		GlobalSignals.play_audio.emit(player_turn_sound, AudioManager.AUDIO_TYPE.UI)
		pass
	else:
		#TODO
		GlobalSignals.play_audio.emit(turn_change_sound, AudioManager.AUDIO_TYPE.UI)
		pass

func _char_died(dead_char:GameCharacter) -> void:
	if dead_char in player_team: player_team.erase(dead_char)
	elif dead_char in enemy_team: enemy_team.erase(dead_char)
	chars_in_combat.erase(dead_char)
	round_order.erase(dead_char)
	dead_char.died.disconnect(_char_died)
	
	if len(enemy_team) == 0:
		_end_combat()
		return
		
	if dead_char == player:
		#TODO end game
		return
		
	if char_to_act == dead_char: _next_turn()

func _compare_initiative(a:GameCharacter, b:GameCharacter):
	return a.stat_handler.secondary_stats[Stats.SecondaryStat.INITIATIVE] > b.stat_handler.secondary_stats[Stats.SecondaryStat.INITIATIVE]

func _end_combat() -> void:
	GlobalSignals.play_audio.emit(combat_end_music, AudioManager.AUDIO_TYPE.UI)
	pass

func _reset() -> void:
	chars_in_combat = []
	player_team = []
	enemy_team = []
	char_to_act = null
