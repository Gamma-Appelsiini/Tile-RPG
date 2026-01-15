extends Node
class_name CombatManager

signal round_changed(number:int)
signal camera_move_finished
signal returned_to_player_camera

@export var combat_ui:CombatUI = null
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
var spectate_camera_pivot:Node3D = null
var spectate_camera:Camera3D = null
var tile_manager:TileManager = null

func _ready() -> void:
	GlobalSignals.combat_manager = self

func start_combat(new_enemies:Array[GameCharacter]) -> void:
	_reset()
	tile_manager = GlobalSignals.current_level.tile_manager
	tile_manager.reset()
	
	GlobalSignals.combat_start.emit()
	GlobalSignals.play_audio.emit(combat_start_music, AudioManager.AUDIO_TYPE.UI)
	combat_ui.show_text("Combat Start")
	
	player = GlobalSignals.player
	#player.died.connect(_player_died)
	#TODO Add player team
	player_team.push_back(player)
	
	enemy_team = new_enemies
	chars_in_combat = player_team.duplicate() + enemy_team.duplicate()

	for game_char:GameCharacter in chars_in_combat:
		game_char.died.connect(_char_died, true)
		_move_to_tile_after_draw_weapon_animation(game_char)
	
	_set_combat_camera()
	
	await get_tree().create_timer(1).timeout
	_next_round()

func _move_to_tile_after_draw_weapon_animation(game_char:GameCharacter) -> void:
	await game_char.ready_to_move
	tile_manager.set_on_closest_tile(game_char)

func _set_combat_camera() -> void:
	if spectate_camera_pivot: spectate_camera_pivot.queue_free()
	if spectate_camera: spectate_camera.queue_free()
	
	spectate_camera_pivot = player.player_camera.get_parent().duplicate()
	spectate_camera = player.player_camera.duplicate()
	spectate_camera.set_script(CombatCamera)
	spectate_camera.set_process_input(false)
	spectate_camera.set_physics_process(false)
	spectate_camera_pivot.add_child(spectate_camera)
	add_child(spectate_camera_pivot)
	spectate_camera_pivot.global_position = player.player_camera.get_parent().global_position
	
	spectate_camera.make_current()

func _return_to_player_camera() -> void:
	spectate_camera.set_process_input(false)
	spectate_camera.set_physics_process(false)
	_move_camera_to_char(player)
	await camera_move_finished
	player.player_camera.pivot.global_basis = spectate_camera_pivot.global_basis
	player.player_camera.size = spectate_camera.size
	
	player.player_camera.make_current()
	returned_to_player_camera.emit()

func _next_round() -> void:
	combat_ui.set_turn_haver(null)
	round_count += 1
	combat_ui.show_text("Round " + str(round_count))
	round_order = chars_in_combat.duplicate()
	GlobalSignals.play_audio.emit(round_change_sound, AudioManager.AUDIO_TYPE.UI)
	round_changed.emit(round_count)
	
	round_order.sort_custom(_compare_initiative)
	combat_ui.add_characters(round_order)
	await combat_ui.portraits_added
	
	_next_turn()

func _next_turn() -> void:
	if len(round_order) == 0:
		_next_round()
		return
	
	round_order.sort_custom(_compare_initiative)
	char_to_act = round_order[0]
	round_order.erase(char_to_act)
	
	combat_ui.update_portraits(round_order)
	combat_ui.set_turn_haver(char_to_act)
	combat_ui.show_text(char_to_act.display_name + ("'s turn"))
	
	_handle_camera(char_to_act)
	await camera_move_finished
	char_to_act.start_turn.emit()
	
	if char_to_act is Player:
		#TODO
		GlobalSignals.play_audio.emit(player_turn_sound, AudioManager.AUDIO_TYPE.UI)
		_player_turn()
	else:
		#TODO
		GlobalSignals.play_audio.emit(turn_change_sound, AudioManager.AUDIO_TYPE.UI)
		char_to_act.ai_handler.take_turn()
		
	await char_to_act.end_turn
	_next_turn()

func _player_turn() -> void:
	tile_manager.enable_shooting()
	
	await player.end_turn
	tile_manager.disable_shooting()

func _handle_camera(current_actor:GameCharacter) -> void:
	spectate_camera_pivot.reparent(current_actor)
	set_process_input(false)
	_move_camera_to_char(current_actor)
	await camera_move_finished
	
	if current_actor is Player:
		spectate_camera.set_process_input(true)
		spectate_camera.set_physics_process(true)
	else:
		spectate_camera.set_process_input(false)
		spectate_camera.set_physics_process(false)


func _move_camera_to_char(current_actor:GameCharacter) -> void:
	var distance:float = current_actor.global_position.distance_to(spectate_camera_pivot.global_position)
	var time_to_point:float = distance * 0.2 + 0.2
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(spectate_camera_pivot, "global_position", current_actor.global_position, time_to_point)
	await tween.finished
	camera_move_finished.emit()

func _char_died(dead_char:GameCharacter) -> void:
	print_debug("Char died: ", dead_char)
	if dead_char in player_team: player_team.erase(dead_char)
	elif dead_char in enemy_team: enemy_team.erase(dead_char)
	chars_in_combat.erase(dead_char)
	round_order.erase(dead_char)
	dead_char.died.disconnect(_char_died)
	combat_ui.update_portraits(round_order)
	await combat_ui.portraits_added
	
	if len(enemy_team) == 0:
		_end_combat()
		return
		
	if dead_char == player:
		#TODO end game
		_end_combat()
		return
		
	if char_to_act == dead_char: _next_turn()

func _compare_initiative(a:GameCharacter, b:GameCharacter):
	return a.stat_handler.secondary_stats[Stats.SecondaryStat.INITIATIVE] > b.stat_handler.secondary_stats[Stats.SecondaryStat.INITIATIVE]

func _end_combat() -> void:
	_disable_ai_handlers()
	tile_manager.disable_shooting()
	GlobalSignals.play_audio.emit(combat_end_music, AudioManager.AUDIO_TYPE.UI)
	
	_return_to_player_camera()
	await returned_to_player_camera
	GlobalSignals.combat_end.emit()
	
func _disable_ai_handlers() -> void:
	for game_character:GameCharacter in chars_in_combat:
		if game_character.ai_handler: game_character.ai_handler.is_combat_over = true

func _reset() -> void:
	chars_in_combat = []
	player_team = []
	enemy_team = []
	char_to_act = null
