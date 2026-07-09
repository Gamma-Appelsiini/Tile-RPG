extends PanelContainer
class_name DefencePanel

@export var grid_container: GridContainer = null

const STAT_AMOUNT_BOX := preload("uid://baa3wachk2q7f")

func _ready() -> void:
	for def:Stats.Defence in EnumStrings.DEF_NAMES.keys():
		var new_box:StatAmountBox = STAT_AMOUNT_BOX.instantiate()
		new_box.set_stat(def)
		grid_container.add_child(new_box)

func update_defs(sh:StatHandler) -> void:
	for stat_box:StatAmountBox in grid_container.get_children():
		stat_box.update_amount(sh.get_stat_amount(stat_box.stat))
