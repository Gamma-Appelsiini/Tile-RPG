extends PanelContainer
class_name ResistancePanel

@onready var fire_label: Label = %FireLabel
@onready var ice_label: Label = %IceLabel
@onready var lightning_label: Label = %LightningLabel
@onready var mystical_label: Label = %MysticalLabel
@onready var physical_label: Label = %PhysicalLabel
@onready var toxic_label: Label = %ToxicLabel

func update_resistances(sh:StatHandler) -> void:
	fire_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.FIRE])
	ice_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.FROST])
	lightning_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.LIGHTNING])
	mystical_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.MYSTICAL])
	physical_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.PHYSICAL])
	toxic_label.text = _get_res_as_string(sh.resistances[Stats.DmgType.TOXIC])

func _get_res_as_string(res_amount:int) -> String:
	if 10 > res_amount: return "0" + str(res_amount)
	
	return str(res_amount)
