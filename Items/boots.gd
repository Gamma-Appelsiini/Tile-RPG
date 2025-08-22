extends Armor
class_name Boots

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_base_def_prefix,_percent_def_prefix,_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_movement_suffix]

func _movement_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 3)
	new_suffix.type_increase = Stats.ResourceStat.MAX_MOVEMENT
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Pathfinding"
	new_suffix.affix_text = "+" + str(amount) + " Movement"
	
	suffixes.push_back(new_suffix)
