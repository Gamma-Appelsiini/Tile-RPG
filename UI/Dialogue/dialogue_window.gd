extends Control
class_name DialogueWindow

@onready var player_portrait: DialoguePortrait = %DialoguePortrait
@onready var npc_portrait: DialoguePortrait = %DialoguePortrait2
@onready var dialogue_panel: DialoguePanel = %DialoguePanel

var dialogue_resource:DialogueResource = null
var player:Player = null
var speaker:GameCharacter = null
var last_dialogue_line:bool = false
var next_dialogue:DialogueResource = null

func _ready() -> void:
	DialogueSignals.add_signal_func("quit_dialogue", _hide_window)
	GlobalSignals.start_dialogue.connect(start_dialogue)
	dialogue_panel.start_new_dialogue.connect(start_dialogue)
	dialogue_panel.check_attempted.connect(_handle_check)
	dialogue_panel.text_ready.connect(set_process_input.bind(true))
	set_process_input(false)

func set_player(new_player:Player) -> void:
	player = new_player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") or event.is_action_pressed("Jump"):
		if dialogue_resource == null: start_dialogue(next_dialogue)
		else: _proceed_dialogue()

func _set_last() -> void:
	last_dialogue_line = true

func _proceed_dialogue() -> void:
	if last_dialogue_line:
		_handle_last_dialogue()
		return

	var text:String = dialogue_resource.get_next_dialogue()
	var whos_turn:DialogueResource.SPEAKER = dialogue_resource.get_whos_turn()
	_set_current_speaker(whos_turn)
	
	set_process_input(false)
	dialogue_panel.set_text(text)

func _set_current_speaker(whos_turn:DialogueResource.SPEAKER ) -> void:
	if whos_turn == DialogueResource.SPEAKER.PLAYER:
		dialogue_panel.set_text_color(true)
		player_portrait.set_active()
		npc_portrait.set_passive()
	else:
		dialogue_panel.set_text_color()
		player_portrait.set_passive()
		npc_portrait.set_active()

func _handle_last_dialogue() -> void:
	last_dialogue_line = false
	if dialogue_resource == null:
		start_dialogue(next_dialogue)
		return
		
	dialogue_resource.end_of_dialogue()
	
	var choices_exist:bool = _set_choices()
	if dialogue_resource.complete_signal: DialogueSignals.dialogue_signal.emit(dialogue_resource.complete_signal)
	
	#Ends if no next
	if !choices_exist: start_dialogue(dialogue_resource.next_dialogue)

func _set_choices() -> bool:
	var choice_res:DialogueChoicesResource = dialogue_resource.choices_resource
	if choice_res != null:
		set_process_input(false)
		_set_current_speaker(DialogueResource.SPEAKER.PLAYER)
		dialogue_panel.player = player
		var checks:Array[StatCheck] = choice_res.checks
		if len(checks) > 0:
			dialogue_panel.set_stat_checks(checks)
		elif choice_res.choices != null:
			dialogue_panel.set_choices(choice_res.choices)
		return true
		
	return false

func _hide_window() -> void:
	set_process_input(false)
	if dialogue_resource != null:
		#dialogue_resource.end_of_dialogue()
		dialogue_resource.last_text.disconnect(_set_last)
	dialogue_resource = null
	self.visible = false
	GlobalSignals.dialogue_finished.emit()

func _show_window() -> void:
	self.visible = true
	
func start_dialogue(new_dialogue:DialogueResource) -> void:
	if new_dialogue == null:
		_hide_window()
		return
	if dialogue_resource != null: dialogue_resource.last_text.disconnect(_set_last)
	
	dialogue_panel.reset_text()
	last_dialogue_line = false
	dialogue_resource = new_dialogue
	next_dialogue = null
	dialogue_panel.dialogue_choices_res = new_dialogue.choices_resource
	
	speaker = new_dialogue.speaker
	_set_portraits(player, speaker)
	
	dialogue_resource.last_text.connect(_set_last)
	_show_window()
	_proceed_dialogue()
	set_process_input(true)

func _set_portraits(player_char:Player, npc:GameCharacter = null) -> void:
	player_portrait.set_character(player_char)
	if npc: npc_portrait.set_character(npc)

func _handle_check(new_check:StatCheck) -> void:
	var passed_check:bool = new_check.attempt_check(player.stat_handler.main_stats[new_check.stat_type])
	
	if passed_check:
		if new_check.pass_signal:
			DialogueSignals.dialogue_signal.emit(new_check.pass_signal)
			
		if new_check.pass_text:
			dialogue_panel.set_text(new_check.pass_text)
			_set_current_speaker(new_check.pass_turn)
		next_dialogue = (new_check.pass_dialogue)

	else:
		if new_check.fail_signal:
			DialogueSignals.dialogue_signal.emit(new_check.fail_signal)
			
		if new_check.fail_text:
			dialogue_panel.set_text(new_check.fail_text)
			_set_current_speaker(new_check.fail_turn)
		next_dialogue = (new_check.fail_dialogue)
		
	last_dialogue_line = true
	dialogue_resource.last_text.disconnect(_set_last)
	dialogue_resource.end_of_dialogue()
	dialogue_resource = null
	set_process_input(true)
