extends PanelContainer
class_name ResistancePanel

@onready var fire_label: Label = %FireLabel
@onready var ice_label: Label = %IceLabel
@onready var lightning_label: Label = %LightningLabel
@onready var mystical_label: Label = %MysticalLabel
@onready var physical_label: Label = %PhysicalLabel
@onready var toxic_label: Label = %ToxicLabel

const RES_CAP_COLOR:Color = Color(0.67, 0.55, 0.154, 1.0)
const RES_CAP:int = 75

func update_resistances(sh:StatHandler) -> void:
	fire_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.FIRE], fire_label)
	ice_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.FROST], ice_label)
	lightning_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.LIGHTNING], lightning_label)
	mystical_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.MYSTICAL], mystical_label)
	physical_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.PHYSICAL], physical_label)
	toxic_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.TOXIC], toxic_label)

func _get_res_as_string(res_amount:int, label:Label) -> String:
	label.remove_theme_color_override("font_color")
	
	if 10 > res_amount: return "0" + str(res_amount)
	if res_amount >= RES_CAP:
		label.add_theme_color_override("font_color", RES_CAP_COLOR)
		return str(RES_CAP)
	
	return str(res_amount)
