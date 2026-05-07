extends PanelContainer
class_name ReusableButton

@export_category("Button appearance")
@export var button_image: Texture2D = null
@export var button_text: String = ""
@export var button_font: Font = null
@export var button_shadow: Vector2i = Vector2(2,1)
@export var text_size: int = 20
@export var text_color: Color = Color("ffff")
@export var button_color: Color = Color("ffff")
@export var image_size: Vector2 = Vector2(20,20)
@export var press_sound: AudioStream = null
@export var hover_sound: AudioStream = null

@export_category("Assignables")
@export var color_rect: ColorRect = null
@export var texture_button: TextureButton = null
@export var image_rect: TextureRect = null
@export var text_label: Label = null

const HIGHLIGHT_COLOR:Color = Color("ffffff14")
const DARKEN_COLOR:Color = Color("0000002d")

var moused_button:Callable = func():
	color_rect.visible = !color_rect.visible
	
	if !color_rect.visible:
		GlobalSignals.mouse_hovered.emit(-1)
	else:
		GlobalSignals.mouse_hovered.emit(1)
		GlobalSignals.play_audio.emit(hover_sound, AudioManager.AUDIO_TYPE.UI)
	
var pressed_button:Callable = func():
	color_rect.color = DARKEN_COLOR
	text_label.add_theme_font_size_override("font_size", text_size - 1)
	image_rect.custom_minimum_size = image_rect.size - Vector2(2,2)
	GlobalSignals.play_audio.emit(press_sound, AudioManager.AUDIO_TYPE.UI)
	
var released_button:Callable = func():
	color_rect.color = HIGHLIGHT_COLOR
	text_label.add_theme_font_size_override("font_size", text_size)
	image_rect.custom_minimum_size = image_size

func _set_button_appearance() -> void:
	color_rect.color = HIGHLIGHT_COLOR
	image_rect.texture = button_image
	text_label.text = button_text
	if button_font: text_label.add_theme_font_override("font", button_font)
	text_label.add_theme_constant_override("shadow_offset_x", button_shadow.x)
	text_label.add_theme_constant_override("shadow_offset_y", button_shadow.y)
	text_label.add_theme_font_size_override("font_size", text_size)
	image_rect.custom_minimum_size = image_size
	text_label.modulate = text_color
	
	if button_color != Color("ffff"): texture_button.modulate = button_color
	if button_image: image_rect.show()
	if button_text != "": text_label.show()

func _ready() -> void:
	_set_button_appearance()
	
	texture_button.mouse_entered.connect(moused_button)
	texture_button.mouse_exited.connect(moused_button)
	texture_button.button_down.connect(pressed_button)
	texture_button.button_up.connect(released_button)
