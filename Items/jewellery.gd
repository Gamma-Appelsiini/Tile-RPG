extends Equipment
class_name Jewellery

@export var base_skill:Stats.SkillStat = Stats.SkillStat.FOCUS
@export var skill_amount:int = 1

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix,_greed_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_regen_suffix,_barter_suffix]
	
	_aff_generators_to_dict()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"item_type": "res://Tile-RPG/Items/jewellery.gd",
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefix_data,
		"suffixes": suffix_data,
		"item_rarity": item_rarity,
		"base_skill": base_skill,
		"skill_amount": skill_amount,
		"inventory_image": inventory_image.resource_path,
		"item_value": item_value,
		"item_name": item_name,
	}
	
	return equipment_data

func load_from_data(save_data:Dictionary) -> void:
	_load_affixes(save_data)

	self.item_level = save_data["item_level"]
	self.equipment_slot = save_data["equipment_slot"]
	self.item_rarity = save_data["item_rarity"]
	self.base_skill = save_data["base_skill"]
	self.skill_amount = save_data["skill_amount"]
	self.inventory_image = load(save_data["inventory_image"])
	self.item_value = save_data["item_value"]
	self.item_name = save_data["item_name"]

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
