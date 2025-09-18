extends HBoxContainer
class_name StatCheckOption

signal option_pressed(pressed_check:StatCheck)

@export var stat_pic: TextureRect = null
@export var text_label: Label = null
@export var color_ramp:Gradient = null
@export var percentage_label: Label = null

const HOVER_COLOR:Color = Color(0.183, 0.6, 0.604, 1.0)
const DEFAULT_COLOR:Color = Color(0.915, 0.915, 0.915, 1.0)

var player:Player = null
var stat_check:StatCheck = null
var percent_color:Color

func _init() -> void:
	self.mouse_entered.connect(_mouse_entered)
	self.mouse_exited.connect(_mouse_exited)

func set_check(new_check:StatCheck) -> void:
	stat_check = new_check
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[new_check.stat_type])
	stat_pic.texture = stat_texture
	text_label.text = new_check.line_text
	_set_percentage()
	
func _set_percentage() -> void:
	var stat_amount:int = player.stat_handler.main_stats[stat_check.stat_type]
	var percentage:float = stat_check.get_pass_percentage(stat_amount)
	percent_color = color_ramp.sample(percentage)
	
	percentage_label.add_theme_color_override("font_color", percent_color)
	percentage_label.text = str(int(percentage * 100)) + "%"

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		option_pressed.emit(stat_check)

func _mouse_entered() -> void:
	text_label.add_theme_color_override("font_color", HOVER_COLOR)
	percentage_label.add_theme_color_override("font_color", Color(1,1,1))

func _mouse_exited() -> void:
	text_label.add_theme_color_override("font_color", DEFAULT_COLOR)
	percentage_label.add_theme_color_override("font_color", percent_color)
