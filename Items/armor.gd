extends Equipment
class_name Armor

enum DefPercentIncrease {
	ARMOR = 1000,
	EVASION,
	WARD,
}

@export var defence_type:Stats.Defence = Stats.Defence.ARMOR
@export var base_defence:int = 1

var percent_increase:int = 0
var total_defence:int = 0

func _init() -> void:
	item_stats_changed.connect(apply_total_defence)
	
	prefix_funcs = [_base_def_prefix,_percent_def_prefix,_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix]

func _reset_defence() -> void:
	percent_increase = 0
	total_defence = 0

func apply_total_defence() -> void:
	_reset_defence()
	for pref:Affix in prefixes:
		if pref.type_increase in DefPercentIncrease.values():
			percent_increase += pref.increase_amount
		elif pref.type_increase in Stats.Defence.values():
			total_defence += pref.increase_amount
			
	var multiplier:float = 1.0
	if percent_increase > 0: multiplier += float(percent_increase) / 100
	var base:float = total_defence + base_defence
	total_defence = int( base * multiplier )
	
func _base_def_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level * 2)
	new_prefix.type_increase = self.defence_type
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Reinforced"
	new_prefix.affix_text = "+" + str(amount) + " Base " + EnumStrings.DEF_NAMES[self.defence_type]
	
	prefixes.push_back(new_prefix)
	
func _percent_def_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(10, 10 + item_level * 3)
	new_prefix.type_increase = DefPercentIncrease.WARD
	if self.defence_type == Stats.Defence.ARMOR: new_prefix.type_increase = DefPercentIncrease.ARMOR
	elif self.defence_type == Stats.Defence.EVASION: new_prefix.type_increase = DefPercentIncrease.EVASION
	
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Fortified"
	new_prefix.affix_text = "+" + str(amount) + "% Item " + EnumStrings.DEF_NAMES[self.defence_type]
	
	prefixes.push_back(new_prefix)
