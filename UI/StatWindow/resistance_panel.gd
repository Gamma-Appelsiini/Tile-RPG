extends PanelContainer
class_name ResistancePanel

@export var grid_container: GridContainer = null

const RES_CAP_COLOR:Color = Color(0.67, 0.55, 0.154, 1.0)
const NEGATIVE_RES_COLOR:Color = Color(0.89, 0.18, 0.116, 1.0)
const RES_CAP:int = 75
const STAT_AMOUNT_BOX := preload("uid://baa3wachk2q7f")

func _ready() -> void:
	for def:Stats.DmgType in EnumStrings.RES_NAMES.keys():
		if def == Stats.DmgType.PURE: continue
		var new_box:StatAmountBox = STAT_AMOUNT_BOX.instantiate()
		new_box.set_stat(def)
		grid_container.add_child(new_box)

func update_resistances(sh:StatHandler) -> void:
	for stat_box:StatAmountBox in grid_container.get_children():
		stat_box.stat_amount_label.remove_theme_color_override("font_color")
		var amount:int = sh.get_stat_amount(stat_box.stat)
		
		if amount >= RES_CAP:
			stat_box.stat_amount_label.add_theme_color_override("font_color", RES_CAP_COLOR)
			amount = RES_CAP
		elif amount < 0: stat_box.stat_amount_label.add_theme_color_override("font_color", NEGATIVE_RES_COLOR)

		stat_box.update_amount(sh.get_stat_amount(stat_box.stat))
