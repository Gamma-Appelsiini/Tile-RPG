extends HBoxContainer
class_name StatCheckOption

signal option_pressed(pressed_check:StatCheck)

@export var stat_pic: TextureRect = null
@export var text_label: Label = null

var stat_check:StatCheck = null

func set_check(new_check:StatCheck):
	stat_check = new_check
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[new_check.stat_type])
	stat_pic.texture = stat_texture
	text_label.text = new_check.line_text

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		option_pressed.emit(stat_check)
