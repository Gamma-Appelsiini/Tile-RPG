extends PanelContainer
class_name ReusableButton

@export_category("Button appearance")
@export var button_image: Texture2D = null
@export var button_text: String = ""
@export var button_color: Color = Color("ffff")

@export_category("Assignables")
@export var color_rect: ColorRect = null
@export var texture_button: TextureButton = null
@export var image_rect: TextureRect = null
@export var text_label: Label = null


const HIGHLIGHT_COLOR:Color = Color("ffffff14")
const DARKEN_COLOR:Color = Color("0000002d")

var moused_button:Callable = func():
	color_rect.visible = !color_rect.visible
	
var pressed_button:Callable = func():
	color_rect.color = DARKEN_COLOR
	
var released_button:Callable = func():
	color_rect.color = HIGHLIGHT_COLOR

func _set_button_appearance() -> void:
	color_rect.color = HIGHLIGHT_COLOR
	image_rect.texture = button_image
	text_label.text = button_text
	
	if button_image: button_image.show()
	if button_text != "": text_label.show()

func _ready() -> void:
	color_rect.color = HIGHLIGHT_COLOR
	image_rect.texture = button_image
	
	if button_color != Color("ffff"): texture_button.modulate = button_color
	
	texture_button.mouse_entered.connect(moused_button)
	texture_button.mouse_exited.connect(moused_button)
	texture_button.button_down.connect(pressed_button)
	texture_button.button_up.connect(released_button)
