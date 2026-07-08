extends Control
class_name SkillPanel

@export var focus_amount: Label = null
@export var insight_amount: Label = null
@export var vigor_amount: Label = null

const STAT_ICON_MATERIAL := preload("uid://cb4rkkgxtauot")

var stat_handler:StatHandler = null

func _ready() -> void:
	pass

func _set_material(rect:TextureRect, stat_type:Stats.MainStat) -> void:
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	rect.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.MAIN_STAT_COLORS[stat_type]))

func set_stat_handler(new_sh:StatHandler) -> void:
	stat_handler = new_sh
	new_sh.stats_changed.connect(_update_skills)

func _update_skills() -> void:
	focus_amount.text = str(stat_handler.get_stat_amount(Stats.SkillStat.FOCUS))
	insight_amount.text = str(stat_handler.get_stat_amount(Stats.SkillStat.INSIGHT))
	vigor_amount.text = str(stat_handler.get_stat_amount(Stats.SkillStat.VIGOR))
