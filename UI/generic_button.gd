extends PanelContainer
class_name DefaultButton

signal purchased

@export var button_texture_rect: TextureRect = null
@export var glow: ColorRect = null
@export var button_press_sound:AudioStream = null
@export var button_release_sound:AudioStream = null
@export var price_label: Label = null

const BUTTON_DEFAULT := preload("uid://cvx8uabp055aj")
const BUTTON_PRESSED := preload("uid://dle3hrj3db2t8")
const COST_LABEL_THEME := preload("uid://crj6kfsca2qxw")

var mouse_pressed:bool = false

func set_price(amount:int) -> void:
	price_label.text = str(amount)

func set_as_sold() -> void:
	set_process_input(false)
	price_label.add_theme_color_override("font_color", Color(0.79, 0.095, 0.303, 1.0))
	price_label.text = "Sold"
	button_texture_rect.mouse_entered.disconnect(_on_m_enter)
	button_texture_rect.mouse_exited.disconnect(_on_m_leave)

func _ready() -> void:
	set_process_input(false)
	_connect_signals()
	
func _on_m_enter() -> void:
	glow.visible = true
	set_process_input(true)
	
func _on_m_leave() -> void:
	glow.visible = false
	if mouse_pressed == false: set_process_input(false)
	
func _connect_signals() -> void:
	button_texture_rect.mouse_entered.connect(_on_m_enter)
	button_texture_rect.mouse_exited.connect(_on_m_leave)

func _set_text_override() -> void:
	price_label.add_theme_font_size_override("font_size", 28)
	price_label.self_modulate = Color("d1d1d1")
	
func _remove_text_override() -> void:
	price_label.self_modulate = Color("ffffff")
	price_label.remove_theme_font_size_override("font_size")

func _on_mouse_release() -> void:
	mouse_pressed = false
	button_texture_rect.texture = BUTTON_DEFAULT
	_remove_text_override()
	GlobalSignals.play_audio.emit(button_release_sound, AudioManager.AUDIO_TYPE.UI)
	
	if !glow.visible: set_process_input(false)
	else: purchased.emit()

func _on_mouse_press() -> void:
	mouse_pressed = true
	button_texture_rect.texture = BUTTON_PRESSED
	_set_text_override()
	GlobalSignals.play_audio.emit(button_press_sound, AudioManager.AUDIO_TYPE.UI)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"): _on_mouse_press()
	elif event.is_action_released("Left Click"): _on_mouse_release()
