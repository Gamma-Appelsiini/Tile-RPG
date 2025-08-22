extends Equipment
class_name Belt

@export var belt_slots:int = 1

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_stomach_suffix]
	
func _stomach_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 4)
	new_suffix.type_increase = Stats.SecondaryStat.STOMACH_CAPACITY
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Gluttony"
	new_suffix.affix_text = "+" + str(amount) + " Stomach Capacity"
	
	suffixes.push_back(new_suffix)
