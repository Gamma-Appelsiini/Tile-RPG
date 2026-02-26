extends PanelContainer
class_name DefaultButton

@export var button_texture_rect: TextureRect = null
@export var glow: ColorRect = null
@export var button_press_sound:AudioStream = null
@export var button_release_sound:AudioStream = null
@export var price_label: Label = null

const BUTTON_DEFAULT := preload("uid://cvx8uabp055aj")
const BUTTON_PRESSED := preload("uid://dle3hrj3db2t8")
const COST_LABEL_THEME := preload("uid://crj6kfsca2qxw")

var mouse_pressed:bool = false

func _ready() -> void:
	_connect_signals()
	
func _connect_signals() -> void:
	button_texture_rect.mouse_entered.connect(func():
		glow.visible = true
		set_process_input(true)
		)
	button_texture_rect.mouse_exited.connect(func():
		glow.visible = false
		if mouse_pressed == false: set_process(false)
		)

func _set_text_override() -> void:
	price_label.add_theme_font_size_override("font_size", 28)
	price_label.self_modulate = Color("d1d1d1")
	
func _remove_text_override() -> void:
	price_label.self_modulate = Color("ffffff")
	price_label.remove_theme_font_size_override("font_size")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		mouse_pressed = true
		button_texture_rect.texture = BUTTON_PRESSED
		_set_text_override()
		GlobalSignals.play_audio.emit(button_press_sound, AudioManager.AUDIO_TYPE.UI)
	elif event.is_action_released("Left Click"):
		mouse_pressed = false
		button_texture_rect.texture = BUTTON_DEFAULT
		_remove_text_override()
		GlobalSignals.play_audio.emit(button_release_sound, AudioManager.AUDIO_TYPE.UI)
		if !glow.visible: set_process(false)
