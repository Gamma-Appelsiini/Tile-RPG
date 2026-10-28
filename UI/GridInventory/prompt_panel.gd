extends MarginContainer
class_name PromptContainer

signal pressed_label(which:bool)

@export var open_sound:AudioStream = null
@export var prompt_label: Label
@export var yes_label: Label
@export var no_label: Label

const HOVER_COLOR:Color = Color(0.49, 0.507, 1.0, 1.0)

var hovered_label:Label = null

func _ready() -> void:
	set_process_input(false)
	yes_label.mouse_entered.connect(yes_label.add_theme_color_override.bind("font_color", HOVER_COLOR))
	yes_label.mouse_exited.connect(yes_label.remove_theme_color_override.bind("font_color"))
	yes_label.mouse_entered.connect(func(): hovered_label = yes_label)
	yes_label.mouse_exited.connect(func(): hovered_label = null)
	visibility_changed.connect(func(): if visible: GlobalSignals.play_audio.emit(open_sound, AudioManager.AUDIO_TYPE.UI))
	
	no_label.mouse_entered.connect(no_label.add_theme_color_override.bind("font_color", HOVER_COLOR))
	no_label.mouse_exited.connect(no_label.remove_theme_color_override.bind("font_color"))

func _process(_delta: float) -> void:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var offset:Vector2 = Vector2(-size.x / 2, -size.y - 20)
	global_position = mouse_pos + offset

func _input(event: InputEvent) -> void:
	if event.is_action_released("Left Click"):
		if hovered_label == yes_label: pressed_label.emit(true)
		else: pressed_label.emit(false)
		hide()
		set_process_input(false)
	elif event.is_action_pressed("Esc") or event.is_action_pressed("Right Click"):
		pressed_label.emit(false)
		hide()
		set_process_input(false)

func set_item_for_purchase(new_item:Item) -> void:
	set_process(false)
	prompt_label.text = "Purchase " + new_item.item_name + " for " + str(new_item.item_value) + " Bux?"
	yes_label.text = "Yes"
	no_label.show()
	yes_label.show()
	set_process_input(true)
	
func cancel_prompt() -> void:
	hide()
	set_process_input(false)
	set_process(false)
	
func set_item_for_sale(new_item:Item) -> void:
	prompt_label.text = "Sell " + new_item.item_name + " for " + str(new_item.item_value) + " Bux?"
	no_label.hide()
	yes_label.hide()
	set_process(true)
	show()
	
func set_error_message(message:String) -> void:
	set_process(false)
	prompt_label.text = message
	yes_label.text = "Ok"
	yes_label.show()
	no_label.hide()
	set_process_input(true)
