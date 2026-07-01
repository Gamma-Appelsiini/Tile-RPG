extends Control
class_name AbilityTooltip

@export var panel_container: PanelContainer = null
@export var name_label: Label = null
@export var description_label: Label = null
@export var cooldown_label: Label = null
@export var range_label: Label = null
@export var aoe_label: Label = null
@export var sp_label: Label = null
@export var aoe_texture_rect: TextureRect = null
@export var sp_texture_rect: TextureRect = null
@export var range_texture_rect: TextureRect = null
@export var cost_container: HBoxContainer = null
@export var scaling_container: HBoxContainer = null
@export var scaling_label: RichTextLabel = null
@export var damage_container: HBoxContainer = null
@export var dmg_description_label: RichTextLabel = null
@export var warning_label: Label = null

var ability:Ability = null

func set_ability(new_ability:Ability) -> void:
	ability = new_ability
	name_label.text = new_ability.ability_name
	_set_ap_cost()
	_set_desc()
	_set_scaling()
	update_tooltip()

func _check_weapon_validity() -> void:
	if ability.has_required_weapon_type(): warning_label.hide()
	else: warning_label.show()

func update_tooltip() -> void:
	cooldown_label.text = str(ability.get_cd())
	_set_value_label(ability.get_range(), range_label, range_texture_rect)
	_set_value_label(ability.get_aoe(), aoe_label, aoe_texture_rect)
	_set_value_label(ability.get_sp_cost(), sp_label, sp_texture_rect)
	_check_weapon_validity()

func _set_value_label(amount:int, label:Label, image_rect:TextureRect) -> void:
	label.text = str(amount)
	if amount == 0:
		label.hide()
		image_rect.hide()
	else:
		label.show()
		image_rect.show()

func _set_scaling() -> void:
	if ability.scaling_desc == "": scaling_container.hide()
	else: scaling_container.show()
	
	scaling_label.text = ability.scaling_desc

func _set_ap_cost() -> void:
	for node:TextureRect in cost_container.get_children():
		node.show()
	
	var orbs_to_hide:int = abs(ability.get_ap_cost() - len(cost_container.get_children()))
	
	while orbs_to_hide - 1 >= 0:
		cost_container.get_children()[orbs_to_hide].hide()
		orbs_to_hide -= 1

func _set_desc() -> void:
	dmg_description_label.text = ability.damage_desc
	if ability.damage_desc == "": damage_container.hide()
	else: damage_container.show()
	
	description_label.text = ability.ability_desc
