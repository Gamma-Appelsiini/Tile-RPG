extends Control
class_name AbilityTooltip

@export var panel_container: PanelContainer = null
@export var name_label: Label = null
@export var description_label: Label = null
@export var cooldown_label: Label = null
@export var range_label: Label = null
@export var aoe_label: Label = null
@export var sp_label: Label = null
@export var damages_container: HBoxContainer = null
@export var aoe_texture_rect: TextureRect = null
@export var sp_texture_rect: TextureRect = null
@export var range_texture_rect: TextureRect = null
@export var cost_container: HBoxContainer = null
@export var dmg_desc_label: Label = null

var ability:Ability = null

func set_ability(new_ability:Ability) -> void:
	ability = new_ability
	name_label.text = new_ability.ability_name
	_set_ap_cost()
	_set_desc()
	update_tooltip()

func update_tooltip() -> void:
	cooldown_label.text = str(ability.get_cd())
	
	_set_value_label(ability.get_range(), range_label, range_texture_rect)
	_set_value_label(ability.get_aoe(), aoe_label, aoe_texture_rect)
	_set_value_label(ability.get_sp_cost(), sp_label, sp_texture_rect)
	_set_damages(ability.get_dmg())

func _set_value_label(amount:int, label:Label, image_rect:TextureRect) -> void:
	label.text = str(amount)
	if amount == 0:
		label.hide()
		image_rect.hide()
	else:
		label.show()
		image_rect.show()

func _set_ap_cost() -> void:
	var orbs_to_remove:int = abs(ability.get_ap_cost() - len(cost_container.get_children()))
	
	while orbs_to_remove - 1 >= 0:
		cost_container.get_children()[orbs_to_remove].hide()
		orbs_to_remove -= 1

func _set_desc() -> void:
	dmg_desc_label.text = ability.damage_desc
	print(ability.ability_desc)
	description_label.text = ability.ability_desc

func _set_damages(damages:Dictionary[Stats.DmgType,int]) -> void:
	for node:Node2D in damages_container.get_children(): node.queue_free()
	if damages.is_empty(): return
	
	for dmg_type:Stats.DmgType in damages.keys():
		if damages[dmg_type] <= 0: continue
		var new_label:Label = sp_label.duplicate()
		new_label.text = str(damages[dmg_type])
