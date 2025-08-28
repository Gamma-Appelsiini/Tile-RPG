extends Equipment
class_name Belt

@export var belt_slots:int = 1

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix,_health_prefix,_thorns_prefix,
	_spell_crit_prefix,_spell_base_crit_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_stomach_suffix]
	_aff_generators_to_dict()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"equipment_type": "res://Tile-RPG/Items/belt.gd",
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefix_data,
		"suffixes": suffix_data,
		"item_rarity": item_rarity,
		"belt_slots": belt_slots,
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
	self.belt_slots = save_data["belt_slots"]
	self.inventory_image = load(save_data["inventory_image"])
	self.item_value = save_data["item_value"]
	self.item_name = save_data["item_name"]
	
func _stomach_suffix() -> void:
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 4)
	new_suffix.type_increase = Stats.SecondaryStat.STOMACH_CAPACITY
	new_suffix.increase_amount = amount
	new_suffix.affix_name = "Gluttony"
	new_suffix.affix_text = "+" + str(amount) + " Stomach Capacity"
	
	suffixes.push_back(new_suffix)
