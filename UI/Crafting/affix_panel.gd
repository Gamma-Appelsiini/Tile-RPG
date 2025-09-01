extends PanelContainer
class_name AffixPanel

@export var affix_text: Label
@export var affix_name: Label
@onready var glow_effect: NinePatchRect = %GlowEffect

const DEL_COLOR:Color = Color("#d94130")
const NORMAL_COLOR:Color = Color("#ffffff")
var affix:Affix = null

func set_affix(new_affix:Affix) -> void:
	affix = new_affix
	affix_name.text = new_affix.affix_name
	affix_text.text = new_affix.affix_text

func show_glow(to_delete:bool = false) -> void:
	if to_delete: glow_effect.self_modulate = DEL_COLOR
	else: glow_effect.self_modulate = NORMAL_COLOR
	
	glow_effect.visible = true
	
func hide_glow() -> void:
	glow_effect.visible = false
