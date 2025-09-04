extends Armor
class_name Shield

#Shields only Block, Spell Block, Dodge, Spell Dodge, Glance

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_shield_base_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_spell_block_suffix]
	
	_aff_generators_to_dict()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"item_type": "res://Tile-RPG/Items/shield.gd",
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefix_data,
		"suffixes": suffix_data,
		"item_rarity": item_rarity,
		"defence_type": defence_type,
		"base_defence": base_defence,
		"percent_increase": percent_increase,
		"total_defence": total_defence,
		"inventory_image": inventory_image.resource_path,
		"item_value": item_value,
		"item_name": item_name,
	}
	
	return equipment_data

func _shield_base_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level * 2)
	new_prefix.type_increase = self.defence_type
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Robust"
	new_prefix.affix_text = "+" + str(amount) + "% Chance to " + EnumStrings.DEF_NAMES[self.defence_type]
	
	prefixes.push_back(new_prefix)

func _spell_block_suffix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 10 + item_level)
	new_prefix.type_increase = Stats.Defence.SPELL_BLOCK
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Guardian"
	new_prefix.affix_text = "+" + str(amount) + "% Spell Block Chance"
	
	suffixes.push_back(new_prefix)
