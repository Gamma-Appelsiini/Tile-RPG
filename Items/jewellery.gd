extends Equipment
class_name Jewellery

@export var base_skill:Stats.SkillStat = Stats.SkillStat.FOCUS
@export var skill_amount:int = 1

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix,_greed_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_regen_suffix,_barter_suffix]

func _regen_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_suffix.type_increase = Stats.SecondaryStat.HEALTH_REGEN
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Invigorating"
	new_suffix.affix_text = "+" + str(amount) + " Health Regen"
	
	suffixes.push_back(new_suffix)
	
func _greed_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_prefix.type_increase = Stats.SecondaryStat.GREED
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Greedy"
	new_prefix.affix_text = "+" + str(amount) + " Greed"
	
	prefixes.push_back(new_prefix)
	
func _barter_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_suffix.type_increase = Stats.SecondaryStat.BARTER
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Bartering"
	new_suffix.affix_text = "+" + str(amount) + " Barter"
	
	suffixes.push_back(new_suffix)
