extends MarginContainer
class_name PromptContainer

signal pressed_label(which:bool)

@export var corner_rect: NinePatchRect
@export var margin_container: MarginContainer
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
	
	no_label.mouse_entered.connect(no_label.add_theme_color_override.bind("font_color", HOVER_COLOR))
	no_label.mouse_exited.connect(no_label.remove_theme_color_override.bind("font_color"))
	#no_label.mouse_entered.connect(func(): hovered_label = no_label)
	#no_label.mouse_exited.connect(func(): hovered_label = null)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if hovered_label == yes_label: pressed_label.emit(true)
		else: pressed_label.emit(false)
		hide()
		set_process_input(false)
	elif event.is_action_pressed("Esc") or event.is_action_pressed("Right Click"):
		pressed_label.emit(false)
		hide()
		set_process_input(false)

func set_item_for_purchase(new_item:Item) -> void:
	prompt_label.text = "Purchase " + new_item.item_name + " for " + str(new_item.item_value) + " Bux?"
	set_process_input(true)
