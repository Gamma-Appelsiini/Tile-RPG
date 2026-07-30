extends PanelContainer
class_name AttackInfoPanel

@export var accuracy_rect: TextureRect = null
@export var crit_rect: TextureRect = null
@export var dmg_rect: TextureRect = null
@export var accuracy_label: Label = null
@export var crit_label: Label = null
@export var dmg_label: Label = null
@export var name_label: Label = null
@export var left_arrow: TextureRect = null
@export var right_arrow: TextureRect = null
@export var nine_patch_rect: NinePatchRect = null

const DAMAGE_PIC := preload("uid://djhr5n3yki3di")
const HEAL_PIC := preload("uid://bvjwrql1tms1w")
const BUFF_PIC := preload("uid://d1jo3g26bjkum")
const DEFAULT_COLOR:Color = Color("666666")
const DMG_COLOR:Color = Color("e6272d")
const HEAL_COLOR:Color = Color("21c460")
const BUFF_COLOR:Color = Color("25c3db")

var game_char:GameCharacter = null
var pulse_color:Color = Color(1.0, 1.0, 1.0, 1.0)
var pulse_tween: Tween = null

func _ready() -> void:
	hide()
	accuracy_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.ACCURACY]
	crit_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.CRIT]
	dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.DAMAGE]

func _pulse_color() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
		
	if !visible:
		return

	const PULSE_TIME: float = 0.6
	nine_patch_rect.modulate = DEFAULT_COLOR
	left_arrow.modulate = DEFAULT_COLOR
	right_arrow.modulate = DEFAULT_COLOR

	pulse_tween = create_tween().set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

	pulse_tween.tween_property(nine_patch_rect, "modulate", pulse_color, PULSE_TIME)
	pulse_tween.parallel().tween_property(left_arrow, "modulate", pulse_color, PULSE_TIME)
	pulse_tween.parallel().tween_property(right_arrow, "modulate", pulse_color, PULSE_TIME)

	pulse_tween.tween_property(nine_patch_rect, "modulate", DEFAULT_COLOR, PULSE_TIME)
	pulse_tween.parallel().tween_property(left_arrow, "modulate", Color(1.0, 1.0, 1.0, 1.0), PULSE_TIME)
	pulse_tween.parallel().tween_property(right_arrow, "modulate", Color(1.0, 1.0, 1.0, 1.0), PULSE_TIME)

func _set_damage(receiver:GameCharacter, ability:Ability) -> void:
	const NUMBER_FONT_SIZE:int = 44
	const TEXT_FONT_SIZE:int = 32
	dmg_label.add_theme_font_size_override("font_size", NUMBER_FONT_SIZE)
	
	var min_dmg:String = ""
	var max_dmg:String = ""
	
	if ability.ability_tags.has(Ability.ABILITY_TAG.DAMAGE):
		dmg_rect.texture = DAMAGE_PIC
		dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.DAMAGE]
		min_dmg = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(true)))
		max_dmg = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(false, true)))
		pulse_color = DMG_COLOR
	elif ability.ability_tags.has(Ability.ABILITY_TAG.HEAL):
		dmg_rect.texture = HEAL_PIC
		dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.HEAL]
		min_dmg = str(ability.get_heal_range().x)
		max_dmg = str(ability.get_heal_range().y)
		pulse_color = HEAL_COLOR
	elif ability.ability_tags.has(Ability.ABILITY_TAG.BUFF):
		dmg_rect.texture = BUFF_PIC
		dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.BUFF]
		dmg_label.text = ability.get_buff_name()
		dmg_label.add_theme_font_size_override("font_size", TEXT_FONT_SIZE)
		pulse_color = BUFF_COLOR
		return
	
	if min_dmg == max_dmg: dmg_label.text = min_dmg
	else: dmg_label.text = min_dmg + "-" + max_dmg

func _set_crit(ability:Ability) -> void:
	if ability.ability_tags.has(Ability.ABILITY_TAG.CANT_CRIT):
		crit_label.hide()
		crit_rect.hide()
	else:
		crit_rect.show()
		crit_label.show()
		crit_label.text = str(int(ability.get_crit_chance() * 100)) + "%"

func set_amounts(receiver:GameCharacter, ability:Ability) -> void:
	game_char = receiver
	name_label.text = ability.ability_name
	
	_set_crit(ability)
	
	if ability.ability_tags.has(Ability.ABILITY_TAG.UNEVADEABLE):accuracy_label.text = "100%"
	else: accuracy_label.text = str(AttackHandler.get_hit_chance(receiver, ability.get_attack())) + "%"
	
	_set_damage(receiver, ability)

func _physics_process(_delta: float) -> void:
	if self.visible == false:
		set_physics_process(false)
		return
	
	_set_screen_position()
	
func _set_screen_position() -> void:
	if !game_char:
		hide()
		return
	if game_char.infobar.modulate.a == 0:
		modulate.a = 0
		return
	
	modulate.a = 1
	var screen_position: Vector2 = game_char.infobar.global_position
	var is_on_right_side := screen_position.x + size.x * 0.5 > get_viewport().get_visible_rect().size.x * 0.5
	var offset := Vector2(game_char.infobar.size.x, 0)
	left_arrow.show()
	right_arrow.hide()
	
	if is_on_right_side:
		offset = Vector2(-size.x / 2, 0)
		left_arrow.hide()
		right_arrow.show()
	
	var target_position := screen_position + offset
	global_position = target_position

func show_info() -> void:
	set_physics_process(true)
	show()
	_pulse_color()
