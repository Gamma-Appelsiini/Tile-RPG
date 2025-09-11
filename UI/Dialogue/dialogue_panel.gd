extends PanelContainer
class_name DialoguePanel

@onready var name_label: Label = %NameLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var options_container: VBoxContainer = %OptionsContainer
#@onready var continue_rect: TextureRect = %ContinueRect

const STAT_CHECK_OPTION = preload("res://Tile-RPG/UI/Dialogue/stat_check_option.tscn")
const TIME_PER_LETTER:float = 0.04

func set_text(next_text:String, speaker_name:String = "") -> void:
	if speaker_name != "": name_label.text = speaker_name
	_change_label_text(dialogue_label, next_text)

func set_stat_checks(checks:Array[StatCheck]) -> void:
	for check:StatCheck in checks:
		var new_option:StatCheckOption = STAT_CHECK_OPTION.instantiate()
		
		new_option.set_check(check)
		new_option.option_pressed.connect(_option_pressed)
		options_container.add_child(new_option)

func _option_pressed(check:StatCheck) -> void:
	for option:StatCheckOption in options_container.get_children():
		option.queue_free()
	

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
