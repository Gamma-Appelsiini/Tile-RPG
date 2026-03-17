extends PanelContainer
class_name DialoguePanel

signal check_attempted(check:StatCheck)
signal start_new_dialogue(dr:DialogueResource)
signal text_ready

@export var dialogue_label: Label = null
@export var choice_container: VBoxContainer = null
@export var continue_rect: TextureRect = null

const STAT_CHECK_OPTION = preload("res://Tile-RPG/UI/Dialogue/stat_check_option.tscn")
const TIME_PER_LETTER:float = 0.025
const PLAYER_TEXT_COLOR:Color = Color(0.909, 0.773, 0.507, 1.0)
const DEFAULT_TEXT_COLOR:Color = Color(1.0, 1.0, 1.0, 1.0)
const HOVER_COLOR:Color = Color(0.183, 0.6, 0.604, 1.0)

var dialogue_choices_res:DialogueChoicesResource = null
var hovered_choice_number:int = -1
var player:Player = null
var choice_labels:Array[Label] = []
var text_tween:Tween = null
var show_continue_rect:bool = true

func reset_text() -> void:
	dialogue_label.text = ""

func set_text(next_text:String) -> void:
	_change_label_text(dialogue_label, next_text)

func set_text_color(is_player_text:bool = false) -> void:
	if is_player_text:
		dialogue_label.add_theme_color_override("font_color", PLAYER_TEXT_COLOR)
		return
		
	dialogue_label.add_theme_color_override("font_color", DEFAULT_TEXT_COLOR)

func set_choices(choices:Array[String]) -> void:
	clear_choices()
	_hide_continue()
	choice_labels = []
	dialogue_label.text = ""
	dialogue_label.visible = false
	
	var place:int = 0
	
	for choice:String in choices:
		var new_container:HBoxContainer = HBoxContainer.new()
		new_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		new_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		new_container.mouse_exited.connect(_choice_exited.bind(place))
		new_container.mouse_entered.connect(_choice_hovered.bind(place))
		new_container.gui_input.connect(_choice_pressed)
		new_container.visible = true
		
		var new_choice:Label = dialogue_label.duplicate()
		new_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_choice.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		new_choice.visible = true
		new_choice.text = choice
		choice_labels.push_back(new_choice)
		
		new_container.add_child(new_choice)
		choice_container.add_child(new_container)
		place += 1

func _choice_exited(choice_number:int) -> void:
	if hovered_choice_number == choice_number:
		hovered_choice_number = -1
		choice_labels[choice_number].add_theme_color_override("font_color", PLAYER_TEXT_COLOR)

func _choice_hovered(choice_number:int) -> void:
	hovered_choice_number = choice_number
	choice_labels[choice_number].add_theme_color_override("font_color", HOVER_COLOR)

func _choice_pressed(event: InputEvent) -> void:
	if !event.is_action_pressed("Left Click"): return
	if hovered_choice_number == -1: return
	var choice_number:int = hovered_choice_number
	
	dialogue_label.visible = true
	clear_choices()
	
	#Does signal for choice exist
	var signal_amount:int = len(dialogue_choices_res.choices_signals)
	if signal_amount -1 >= choice_number:
		var signal_id:String = dialogue_choices_res.choices_signals[choice_number]
		DialogueSignals.dialogue_signal.emit(signal_id)

	#Does next dialogue for choice exist
	var next_dialogue_amount:int = len(dialogue_choices_res.next_dialogues)
	if next_dialogue_amount -1  >= choice_number:
		var next_dialogue:DialogueResource = dialogue_choices_res.next_dialogues[choice_number]
		start_new_dialogue.emit(next_dialogue)

func clear_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()

func set_stat_checks(checks:Array[StatCheck]) -> void:
	_hide_continue()
	
	dialogue_label.text = ""
	dialogue_label.visible = false
	
	for check:StatCheck in checks:
		var new_choice:StatCheckOption = STAT_CHECK_OPTION.instantiate()
		new_choice.player = player
		
		new_choice.set_check(check)
		new_choice.option_pressed.connect(_check_option_pressed)
		choice_container.add_child(new_choice)

func _check_option_pressed(check:StatCheck) -> void:
	dialogue_label.visible = true
	for choice:StatCheckOption in choice_container.get_children():
		choice.queue_free()
	
	check_attempted.emit(check)
	
func _hide_continue() -> void:
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_parallel(true)
	tween.tween_property(continue_rect, "custom_minimum_size:x", 0, 0.1)
	tween.tween_property(continue_rect, "modulate:a", 0, 0.1)

func _show_continue() -> void:
	if !show_continue_rect: return
	
	continue_rect.custom_minimum_size.x = 0
	continue_rect.visible = true
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(continue_rect, "custom_minimum_size:x", 50, 0.1)
	tween.tween_property(continue_rect, "modulate:a", 1, 0.1)

func _change_label_text(label:Label,new_text:String, time_override:float = 0):
	_hide_continue()
	if text_tween != null: text_tween.stop()
	
	var change_time = new_text.length() * TIME_PER_LETTER
	if time_override != 0: change_time = time_override
	
	label.text = ""
	text_tween = create_tween()
	text_tween.tween_property(label,"text",new_text, change_time).set_ease(Tween.EASE_OUT)
	await text_tween.finished
	text_tween = null
	
	text_ready.emit()
	_show_continue()
