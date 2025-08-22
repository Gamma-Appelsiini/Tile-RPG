extends Armor
class_name Gloves

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_base_def_prefix,_percent_def_prefix,_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_initiative_suffix]

func _initiative_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_suffix.type_increase = Stats.SecondaryStat.INITIATIVE
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Swiftness"
	new_suffix.affix_text = "+" + str(amount) + " Initiative"
	
	suffixes.push_back(new_suffix)

func _life_on_hit_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, int((item_level+1) / 2))
	new_prefix.type_increase = Stats.SecondaryStat.LIFE_ON_HIT
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Leeching"
	new_prefix.affix_text = "+" + str(amount) + " Life on Hit"
	
	prefixes.push_back(new_prefix)
