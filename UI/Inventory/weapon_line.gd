extends HBoxContainer
class_name WeaponLine

@export var label_1: Label
@export var label_2: Label

func set_text(text1:String,text2:String,color_override:Color = Color("ffffff")) -> void:
	label_1.text = text1
	label_2.text = text2
	
	label_2.add_theme_color_override("font_color",color_override)
