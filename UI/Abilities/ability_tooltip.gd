extends Control
class_name AbilityTooltip

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var cooldown_label: Label = %CooldownLabel
@onready var range_label: Label = %RangeLabel
@onready var aoe_label: Label = %AoeLabel
@onready var sp_label: Label = %SpLabel
@onready var damages_container: HBoxContainer = %DamagesContainer

var ability:Ability = null

func set_ability(new_ability:Ability) -> void:
	ability = new_ability
	
	name_label.text = new_ability.ability_name
	update_tooltip()

func update_tooltip() -> void:
	description_label.text = ability.get_description()
	cooldown_label.text = str(ability.get_cd())
	range_label.text = str(ability.get_range())
	
	aoe_label.text = str(ability.get_aoe())
	if ability.get_aoe() == 0: aoe_label.hide()
	
	sp_label.text = str(ability.get_sp_cost())
	if ability.get_sp_cost() == 0: sp_label.hide()
	
	_set_damages(ability.get_dmg())

func _set_damages(damages:Dictionary[Stats.DmgType,int]) -> void:
	for node:Node2D in damages_container.get_children(): node.queue_free()
	if damages.is_empty(): return
	
	for dmg_type:Stats.DmgType in damages.keys():
		if damages[dmg_type] <= 0: continue
		var new_label:Label = sp_label.duplicate()
		new_label.text = str(damages[dmg_type])
