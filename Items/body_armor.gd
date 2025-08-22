extends Armor
class_name BodyArmor

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_base_def_prefix,_percent_def_prefix,_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_spirit_suffix]

func _spirit_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_suffix.type_increase = Stats.ResourceStat.MAX_SPIRIT
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Limitless"
	new_suffix.affix_text = "+" + str(amount) + " Max Spirit"
	
	suffixes.push_back(new_suffix)
