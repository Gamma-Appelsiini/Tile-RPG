extends PanelContainer
class_name AffixPanel

@export var affix_text: Label
@export var affix_name: Label
@export var glow_effect: NinePatchRect
@export var corner_shadow: NinePatchRect
@export var right_diamond: TextureProgressBar
@export var left_diamond: TextureProgressBar

const DEL_COLOR:Color = Color("#d94130")
const NORMAL_COLOR:Color = Color("#ffffff")
var affix:Affix = null

func _ready() -> void:
	mouse_entered.connect(func():
		glow_effect.show()
		corner_shadow.hide()
		right_diamond.show()
		left_diamond.show()
		)
	mouse_exited.connect(func():
		glow_effect.hide()
		corner_shadow.show()
		left_diamond.hide()
		right_diamond.hide()
		)

func set_affix(new_affix:Affix) -> void:
	affix = new_affix
	affix_name.text = new_affix.affix_name
	affix_text.text = new_affix.affix_text
