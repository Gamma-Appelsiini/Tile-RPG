extends PanelContainer
class_name DialoguePanel

signal check_attempted(check:StatCheck)
signal start_new_dialogue(dr:DialogueResource)

@onready var name_label: Label = %NameLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var choice_container: VBoxContainer = %OptionsContainer
#@onready var continue_rect: TextureRect = %ContinueRect

const STAT_CHECK_OPTION = preload("res://Tile-RPG/UI/Dialogue/stat_check_option.tscn")
const TIME_PER_LETTER:float = 0.04

var dialogue_choices_res:DialogueChoicesResource = null
var hovered_choice_number:int = -1

func set_text(next_text:String) -> void:
	_change_label_text(dialogue_label, next_text)

func set_name_label(name_text:String) -> void:
	name_label.text = name_text

func set_choices(options:Array[String]) -> void:
	dialogue_label.text = ""
	dialogue_label.visible = false
	var place:int = 0
	
	for choice:String in options:
		var new_choice:Label = dialogue_label.duplicate()
		
		new_choice.text = choice
		new_choice.mouse_exited.connect(_choice_exited.bind(place))
		new_choice.mouse_entered.connect(_choice_hovered.bind(place))
		new_choice.gui_input.connect(_choice_pressed)
		choice_container.add_child(new_choice)

func _choice_exited(choice_number:int) -> void:
	if hovered_choice_number == choice_number: hovered_choice_number = -1

func _choice_hovered(choice_number:int) -> void:
	hovered_choice_number = choice_number

func _choice_pressed(event: InputEvent) -> void:
	if hovered_choice_number == -1: return
	
	_clear_choices()
	if event.is_action_pressed("Left Click"):
		#Does signal for choice exist
		if len(dialogue_choices_res.choices_signals)-1 >= hovered_choice_number:
			var signal_id:String = dialogue_choices_res.choices_signals[hovered_choice_number]
			DialogueSignals.dialogue_signal.emit(signal_id)

		#Does next dialogue for choice exist
		if len(dialogue_choices_res.next_dialogues)-1 >= hovered_choice_number:
			var next_dialogue:DialogueResource = dialogue_choices_res.next_dialogues[hovered_choice_number]
			start_new_dialogue.emit(next_dialogue)

func _clear_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()

func set_stat_checks(checks:Array[StatCheck]) -> void:
	dialogue_label.text = ""
	dialogue_label.visible = false
	
	for check:StatCheck in checks:
		var new_choice:StatCheckOption = STAT_CHECK_OPTION.instantiate()
		
		new_choice.set_check(check)
		new_choice._check_option_pressed.connect(_choice_pressed)
		choice_container.add_child(new_choice)

func _check_option_pressed(check:StatCheck) -> void:
	dialogue_label.visible = true
	for choice:StatCheckOption in choice_container.get_children():
		choice.queue_free()
	
	check_attempted.emit(check)
	
func _change_label_text(label:Label,new_text:String, time_override:float = 0):
	set_process_input(false)
	#continue_rect.visible = false

	var change_time = new_text.length() * TIME_PER_LETTER
	if time_override != 0: change_time = time_override
	
	label.text = ""
	var tween:Tween = create_tween().set_parallel(true)
	tween.tween_property(label,"text",new_text, change_time).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	set_process_input(true)
	#continue_rect.visible = true
