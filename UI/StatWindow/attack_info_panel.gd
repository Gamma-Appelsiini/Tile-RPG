extends PanelContainer
class_name AttackInfoPanel

@export var accuracy_rect: TextureRect = null
@export var crit_rect: TextureRect = null
@export var dmg_rect: TextureRect = null
@export var accuracy_label: Label = null
@export var crit_label: Label = null
@export var dmg_label: Label = null
@export var name_label: Label = null

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
	
	var current_camera:Camera3D =  get_viewport().get_camera_3d()
	var screen_position:Vector2 = current_camera.unproject_position(game_char.heigth_node.global_transform.origin)
	var offset:Vector2 = Vector2(-self.size.x/3, -self.size.y) + Vector2(0,5)
	self.global_position = screen_position + offset

func show_info() -> void:
	set_physics_process(true)
	show()
