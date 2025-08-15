extends PanelContainer
class_name ResistancePanel

@onready var fire_label: Label = %FireLabel
@onready var ice_label: Label = %IceLabel
@onready var lightning_label: Label = %LightningLabel
@onready var mystical_label: Label = %MysticalLabel
@onready var physical_label: Label = %PhysicalLabel
@onready var toxic_label: Label = %ToxicLabel

func update_resistances(sh:StatHandler):
	fire_label.text = str(sh.resistances[Stats.DmgType.FIRE])
	ice_label.text = str(sh.resistances[Stats.DmgType.FROST])
	lightning_label.text = str(sh.resistances[Stats.DmgType.LIGHTNING])
	mystical_label.text = str(sh.resistances[Stats.DmgType.MYSTICAL])
	physical_label.text = str(sh.resistances[Stats.DmgType.PHYSICAL])
	toxic_label.text = str(sh.resistances[Stats.DmgType.TOXIC])
