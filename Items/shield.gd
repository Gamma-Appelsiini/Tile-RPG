extends Armor
class_name Shield

#Shields only Block, Spell Block, Dodge, Spell Dodge, Glance

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_shield_base_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix]
	
func _shield_base_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level * 2)
	new_prefix.type_increase = self.defence_type
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Robust"
	new_prefix.affix_text = "+" + str(amount) + "% Chance to " + EnumStrings.DEF_NAMES[self.defence_type]
	
	prefixes.push_back(new_prefix)
