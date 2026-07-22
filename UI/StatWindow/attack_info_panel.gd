extends PanelContainer
class_name AttackInfoPanel

@onready var accuracy_rect: TextureRect = $VBoxContainer/HBoxContainer/AccuracyContainer/AccuracyRect
@onready var crit_rect: TextureRect = $VBoxContainer/HBoxContainer/CritContainer/CritRect
@onready var dmg_rect: TextureRect = $VBoxContainer/DmgContainer/DmgRect
@onready var accuracy_label: Label = $VBoxContainer/HBoxContainer/AccuracyContainer/AccuracyLabel
@onready var crit_label: Label = $VBoxContainer/HBoxContainer/CritContainer/CritLabel
@onready var dmg_label: Label = $VBoxContainer/DmgContainer/DmgLabel
@onready var name_label: Label = $VBoxContainer/NameLabel

func _ready() -> void:
	accuracy_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.ACCURACY]
	crit_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.CRIT]
	dmg_rect.modulate = EnumStrings.COMBAT_COLORS[Stats.CombatStat.DAMAGE]

func set_amounts(receiver:GameCharacter, ability:Ability) -> void:
	name_label.text = ability.ability_name
	crit_label.text = str(int(ability.get_crit_chance() * 100)) + "%"
	accuracy_label.text = str(AttackHandler.get_hit_chance(receiver, ability.get_attack())) + "%"
	
	var min_dmg:String = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(true)))
	var max_dmg:String = str(AttackHandler.get_expected_damage(receiver,ability.get_attack(false, true)))
	if min_dmg == max_dmg: dmg_label.text = min_dmg
	else: dmg_label.text = min_dmg + "-" + max_dmg
