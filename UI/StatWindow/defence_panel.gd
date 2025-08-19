extends PanelContainer
class_name DefencePanel
@onready var armor_amount: Label = %ArmorAmount
@onready var evasion_amount: Label = %EvasionAmount
@onready var ward_amount: Label = %WardAmount

func update_defs(sh:StatHandler) -> void:
	armor_amount.text = str(sh.defences[Stats.Defence.ARMOR])
	evasion_amount.text = str(sh.defences[Stats.Defence.EVASION])
	ward_amount.text = str(sh.defences[Stats.Defence.WARD])
