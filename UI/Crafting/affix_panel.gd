extends PanelContainer
class_name AffixPanel

@export var affix_text: Label
@export var affix_name: Label

var affix:Affix = null

func set_affix(new_affix:Affix) -> void:
	affix = new_affix
	affix_name.text = new_affix.affix_name
	affix_text.text = new_affix.affix_text
