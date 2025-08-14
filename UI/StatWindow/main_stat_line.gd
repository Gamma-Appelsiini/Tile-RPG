extends Control
class_name StatLine

@onready var stat_pic_rect: TextureRect = %StatPicRect
@onready var stat_name_label: Label = %StatNameLabel
@onready var amount_label: Label = %AmountLabel


func set_stat(stat_type:Stats.MainStat, amount:int) -> void:

	stat_name_label.text = EnumStrings.main_stat_names[stat_type] + ":"
	stat_name_label.add_theme_color_override("font_color", Color(EnumStrings.main_stat_colors[stat_type]))
	stat_name_label.add_theme_color_override("font_outline_color", Color("#000000"))
	stat_name_label.add_theme_constant_override("outline_size", 2)

	amount_label.text = str(amount)
	
	#var stat_texture:Texture2D = load(Stats.main_stat_pics[stat_type])
	#picture.texture = stat_texture

func update_value(amount:int):
	amount_label.text = str(amount)
