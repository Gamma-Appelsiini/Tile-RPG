extends Control
class_name StatLine

@export var stat_pic: TextureRect = null
@export var stat_label: Label = null
@export var number_label: Label = null
var line_stat_type:Stats.MainStat = Stats.MainStat.AGILITY

func set_stat(stat_type:Stats.MainStat, amount:int) -> void:
	line_stat_type = stat_type
	stat_label.text = EnumStrings.MAIN_STAT_NAMES[stat_type]
	
	#stat_label.add_theme_color_override("font_color", Color(EnumStrings.MAIN_STAT_COLORS[stat_type]))
	#stat_label.add_theme_color_override("font_outline_color", Color("#000000"))
	#stat_label.add_theme_constant_override("outline_size", 2)

	number_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[stat_type])
	stat_pic.texture = stat_texture
	stat_pic.self_modulate = EnumStrings.MAIN_STAT_COLORS[stat_type]
