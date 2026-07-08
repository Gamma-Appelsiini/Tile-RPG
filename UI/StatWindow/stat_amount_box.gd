extends VBoxContainer
class_name StatAmountBox

@onready var stat_name_label: Label = $StatNameLabel
@onready var stat_rect: TextureRect = $HBoxContainer/StatRect
@onready var stat_amount_label: Label = %StatAmountLabel

const STAT_ICON_MATERIAL:ShaderMaterial = preload("uid://cb4rkkgxtauot")


func set_skill_stat(skill:Stats.SkillStat, amount:int) -> void:
	stat_name_label.text = EnumStrings.SKILLS_NAMES[skill]
	stat_amount_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.SKILLS_PICS[skill])
	stat_rect.texture = stat_texture
	
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_rect.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.SKILLS_COLORS[skill]))
	
func set_def_stat(def:Stats.Defence, amount:int) -> void:
	stat_name_label.text = EnumStrings.DEF_NAMES[def]
	stat_amount_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.DEF_PICS[def])
	stat_rect.texture = stat_texture
	
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_rect.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.DEF_COLORS[def]))
	
func set_res_stat(res:Stats.DmgType, amount:int) -> void:
	stat_name_label.text = EnumStrings.RES_NAMES[res]
	stat_amount_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.RES_PICS[res])
	stat_rect.texture = stat_texture
	
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_rect.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.RES_COLORS[res]))
	
func update_amount(amount:int) -> void:
	stat_amount_label.text = str(amount)
