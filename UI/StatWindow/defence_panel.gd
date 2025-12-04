extends PanelContainer
class_name DefencePanel

@export var armor_amount: Label = null
@export var evasion_amount: Label = null
@export var ward_amount: Label = null
@export var glance_amount: Label = null
@export var block_amount: Label = null
@export var sblock_amount: Label = null
@export var dodge_amount: Label = null
@export var sdodge_amount: Label = null

func update_defs(sh:StatHandler) -> void:
	armor_amount.text = str(sh.defences[Stats.Defence.ARMOR])
	evasion_amount.text = str(sh.defences[Stats.Defence.EVASION])
	ward_amount.text = str(sh.defences[Stats.Defence.WARD])
	glance_amount.text = str(sh.defences[Stats.Defence.GLANCE])
	block_amount.text = str(sh.defences[Stats.Defence.BLOCK])
	sblock_amount.text = str(sh.defences[Stats.Defence.SPELL_BLOCK])
	dodge_amount.text = str(sh.defences[Stats.Defence.DODGE])
	sdodge_amount.text = str(sh.defences[Stats.Defence.SPELL_DODGE])
