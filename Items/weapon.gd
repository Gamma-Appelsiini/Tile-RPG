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
}

func _init() -> void:
	prefix_funcs = [_dmg_percent_prefix, _spell_crit_prefix,_spell_base_crit_prefix,_weapon_dmg_prefix]
	suffix_funcs = [_mainstat_suffix,_resistance_suffix,_base_crit_suffix,_crit_multilier_suffix]

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
	if reduce_amount > 0: amount - reduce_amount
	
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
	new_prefix.affix_text = "+" + str(amount) + " Base Crit Chance"
	
	suffixes.push_back(new_prefix)

func _crit_multilier_suffix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(10, 50)
	new_prefix.type_increase = WeaponStat.BASE_MULTIPLIER
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Damaging"
	new_prefix.affix_text = "+" + str(amount) + " Base Crit Chance"
	
	suffixes.push_back(new_prefix)

#Overwritten to apply weapon affixes
func add_prefix() -> void:
	var number:int = randi_range(0, len(prefix_funcs)-1)
	prefix_funcs[number].call()
	prefix_funcs.remove_at(number)
	
	var new_affix:Affix = prefixes.back()
	if new_affix.type_increase in weapon_stats.keys():
		self.weapon_stats[new_affix.type_increase] += new_affix.increase_amount
		
	item_stats_changed.emit()

#Overwritten to apply weapon affixes	
func add_suffix() -> void:
	var number:int = randi_range(0, len(suffix_funcs)-1)
	suffix_funcs[number].call()
	suffix_funcs.remove_at(number)
	
	var new_affix:Affix = suffixes.back()
	if new_affix.type_increase in weapon_stats.keys():
		self.weapon_stats[new_affix.type_increase] += new_affix.increase_amount
		
	item_stats_changed.emit()

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
