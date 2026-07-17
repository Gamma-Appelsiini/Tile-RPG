extends VBoxContainer
class_name StatAmountBox

@export var stat_name_label: Label = null
@export var stat_rect: TextureRect = null
@export var stat_amount_label: Label = null

const STAT_ICON_MATERIAL:ShaderMaterial = preload("uid://cb4rkkgxtauot")
var stat:int = 0

func set_stat(stat_enum:int) -> void:
	stat = stat_enum
	
	if EnumStrings.RES_NAMES.has(stat_enum):
		if stat_enum == Stats.DmgType.PURE: return
		stat_name_label.text = EnumStrings.RES_NAMES[stat_enum]
		stat_rect.texture = load(EnumStrings.RES_PICS[stat_enum])
	elif EnumStrings.DEF_NAMES.has(stat_enum):
		stat_name_label.text = EnumStrings.DEF_NAMES[stat_enum]
		stat_rect.texture = load(EnumStrings.DEF_PICS[stat_enum])
	elif EnumStrings.MAIN_STAT_NAMES.has(stat_enum):
		stat_name_label.text = EnumStrings.MAIN_STAT_NAMES[stat_enum]
		stat_rect.texture = load(EnumStrings.MAIN_STAT_PICS[stat_enum])
	else:
		stat_name_label.text = EnumStrings.SKILLS_NAMES[stat_enum]
		stat_rect.texture = load(EnumStrings.SKILLS_PICS[stat_enum])
		
	_set_material(stat_enum)

func _set_material(stat_number:int) -> void:
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_rect.material = new_material
	var color:Color = Color()
	
	if EnumStrings.RES_COLORS.has(stat_number): color = Color(EnumStrings.RES_COLORS[stat_number])
	elif EnumStrings.DEF_COLORS.has(stat_number): color = Color(EnumStrings.DEF_COLORS[stat_number])
	elif EnumStrings.MAIN_STAT_COLORS.has(stat_number): color = Color(EnumStrings.MAIN_STAT_COLORS[stat_number])
	else: color = Color(EnumStrings.SKILLS_COLORS[stat_number])
	
	new_material.set_shader_parameter("stat_color", color)

func update_amount(amount:int) -> void:
	stat_amount_label.text = str(amount)
