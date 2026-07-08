extends Control
class_name StatLine

@export var stat_pic: TextureRect = null
@export var stat_label: Label = null
@export var number_label: Label = null

const STAT_ICON_MATERIAL := preload("uid://cb4rkkgxtauot")

var line_stat_type:Stats.MainStat = Stats.MainStat.AGILITY

func set_stat(stat_type:Stats.MainStat, amount:int) -> void:
	line_stat_type = stat_type
	stat_label.text = EnumStrings.MAIN_STAT_NAMES[stat_type]
	number_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[stat_type])
	stat_pic.texture = stat_texture
	
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_pic.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.MAIN_STAT_COLORS[stat_type]))
