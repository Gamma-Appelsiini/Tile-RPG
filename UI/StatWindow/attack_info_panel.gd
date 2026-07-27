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

var game_char:GameCharacter = null

func _ready() -> void:
	hide()
	accuracy_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.ACCURACY]
	crit_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.CRIT]
	dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.DAMAGE]

func set_amounts(receiver:GameCharacter, ability:Ability) -> void:
	game_char = receiver
	name_label.text = ability.ability_name
	crit_label.text = str(int(ability.get_crit_chance() * 100)) + "%"
	accuracy_label.text = str(AttackHandler.get_hit_chance(receiver, ability.get_attack())) + "%"
	
	var min_dmg:String = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(true)))
	var max_dmg:String = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(false, true)))
	if min_dmg == max_dmg: dmg_label.text = min_dmg
	else: dmg_label.text = min_dmg + "-" + max_dmg

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
