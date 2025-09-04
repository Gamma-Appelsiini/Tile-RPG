extends Armor
class_name BodyArmor

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_base_def_prefix,_percent_def_prefix,_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_spirit_suffix]
	_aff_generators_to_dict()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"item_type": "res://Tile-RPG/Items/body_armor.gd",
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

func _spirit_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_suffix.type_increase = Stats.ResourceStat.MAX_SPIRIT
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Limitless"
	new_suffix.affix_text = "+" + str(amount) + " Max Spirit"
	
	suffixes.push_back(new_suffix)
