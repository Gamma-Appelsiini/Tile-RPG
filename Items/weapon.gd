extends Equipment
class_name Weapon

enum WeaponType {
	SWORD = 50,
	STAFF,
	AXE,
	DAGGER,
	MACE,
	BOW
}

enum HandType {
	ONE_HANDED,
	TWO_HANDED
}

enum WeaponStat {
	MIN_DMG = 1500,
	MAX_DMG,
	RANGE,
	BASE_CRIT,
	BASE_MULTIPLIER,
	SCALE_AMOUNT,
}

@export var weapon_type:WeaponType = WeaponType.AXE
@export var hand_type:HandType = HandType.ONE_HANDED
@export var scale_stat:Stats.MainStat = Stats.MainStat.MIGHT
@export var damage_type:Stats.DmgType = Stats.DmgType.PHYSICAL

@export var weapon_stats:Dictionary[WeaponStat,int] = {
	WeaponStat.MIN_DMG: 1,
	WeaponStat.MAX_DMG: 1,
	WeaponStat.RANGE: 1,
	WeaponStat.BASE_CRIT: 5,
	WeaponStat.BASE_MULTIPLIER: 100,
	WeaponStat.SCALE_AMOUNT: 100,
}

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix, _spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix,
	_max_dmg_prefix,_min_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_base_crit_suffix,_crit_multilier_suffix]
	
	_aff_generators_to_dict()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"item_type": "res://Tile-RPG/Items/weapon.gd",
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefix_data,
		"suffixes": suffix_data,
		"item_rarity": item_rarity,
		"weapon_type": weapon_type,
		"hand_type": hand_type,
		"scale_stat": scale_stat,
		"damage_type": damage_type,
		"weapon_stats": weapon_stats,
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
	self.weapon_type = save_data["weapon_type"]
	self.hand_type = save_data["hand_type"]
	self.scale_stat = save_data["scale_stat"]
	self.damage_type = save_data["damage_type"]
	self.weapon_stats = save_data["weapon_stats"]
	self.inventory_image = load(save_data["inventory_image"])
	self.item_value = save_data["item_value"]
	self.item_name = save_data["item_name"]

func _max_dmg_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	new_prefix.type_increase = WeaponStat.MAX_DMG
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Deadlier"
	new_prefix.affix_text = "+" + str(amount) + " Max Damage"
	
	prefixes.push_back(new_prefix)
	
func _min_dmg_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	#min dmg cant go over max dmg
	var reduce_amount:int = (amount + self.weapon_stats[WeaponStat.MIN_DMG]) - self.weapon_stats[WeaponStat.MAX_DMG]
	if reduce_amount > 0: amount -= reduce_amount
	
	new_prefix.type_increase = WeaponStat.MIN_DMG
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Consistent"
	new_prefix.affix_text = "+" + str(amount) + " Min Damage"
	
	prefixes.push_back(new_prefix)
	
func _base_crit_suffix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 10)
	new_prefix.type_increase = WeaponStat.BASE_CRIT
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Deadly"
	new_prefix.affix_text = "+" + str(amount) + "% Base Crit Chance"
	
	suffixes.push_back(new_prefix)

func _crit_multilier_suffix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(10, 50)
	new_prefix.type_increase = WeaponStat.BASE_MULTIPLIER
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Damaging"
	new_prefix.affix_text = "+" + str(amount) + "% Base Crit Multiplier"
	
	suffixes.push_back(new_prefix)

#Overwritten to apply weapon affixes
func add_prefix() -> Affix:
	var number:int = randi_range(0, len(prefix_funcs)-1)
	prefix_funcs[number].call()
	
	var new_affix:Affix = prefixes.back()
	new_affix.affix_generator = prefix_funcs[number]
	
	for key:String in aff_funcs.keys():
		if aff_funcs[key] == prefix_funcs[number]:
			new_affix.generator_key = key
	
	prefix_funcs.remove_at(number)

	if new_affix.type_increase in weapon_stats.keys():
		self.weapon_stats[new_affix.type_increase] += new_affix.increase_amount
		
	item_stats_changed.emit()
	return new_affix

#Overwritten to apply weapon affixes	
func add_suffix() -> Affix:
	var number:int = randi_range(0, len(suffix_funcs)-1)
	suffix_funcs[number].call()
	
	var new_affix:Affix = suffixes.back()
	new_affix.affix_generator = suffix_funcs[number]
	
	for key:String in aff_funcs.keys():
		if aff_funcs[key] == suffix_funcs[number]:
			new_affix.generator_key = key
	
	suffix_funcs.remove_at(number)
	
	if new_affix.type_increase in weapon_stats.keys():
		self.weapon_stats[new_affix.type_increase] += new_affix.increase_amount
		
	item_stats_changed.emit()
	return new_affix

#Overwritten to remove weapon affixes
func remove_affix(aff:Affix) -> void:
	if aff in prefixes:
		prefixes.erase(aff)
		prefix_funcs.push_back(aff.affix_generator)
	else:
		suffixes.erase(aff)
		suffix_funcs.push_back(aff.affix_generator)
	
	if aff.type_increase in weapon_stats.keys():
		self.weapon_stats[aff.type_increase] -= aff.increase_amount
	
	var aff_amount:int = suffixes.size() + prefixes.size()
	self.item_rarity = RARITY_MAP[aff_amount]
	
	item_stats_changed.emit()
