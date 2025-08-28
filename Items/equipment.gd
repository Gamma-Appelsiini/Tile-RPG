extends Item
class_name Equipment

signal item_stats_changed

enum EquipmentSlot {
	MAIN_HAND = 1,
	OFF_HAND,
	FEET,
	HEAD,
	NECK,
	FINGER,
	CHEST,
	HANDS,
	WAIST
}

@export var equipment_slot:EquipmentSlot = EquipmentSlot.MAIN_HAND
@export var item_level:int = 1

var max_affixes:int = 2
var prefixes:Array[Affix] = []
var suffixes:Array[Affix] = []

var prefix_funcs:Array[Callable] = []
var suffix_funcs:Array[Callable] = []

var aff_funcs:Dictionary[String, Callable] = {"p0": _mainstat_suffix}

const RARITY_MAP:Dictionary[int,Item.ItemRarity] = {0: Item.ItemRarity.POOR,
	1: Item.ItemRarity.COMMON,
	2: Item.ItemRarity.RARE,
	3: Item.ItemRarity.EPIC,
	4: Item.ItemRarity.LEGENDARY,
	5: Item.ItemRarity.GOD_ROLL,
	6: Item.ItemRarity.GOD_ROLL,}

func _aff_generators_to_dict() -> void:
	var letter:String = "p"
	var number:int = 0
	for function:Callable in prefix_funcs:
		aff_funcs[letter+str(number)] = function
		number += 1
	
	letter = "s"
	number = 0
	for function:Callable in suffix_funcs:
		aff_funcs[letter+str(number)] = function
		number += 1

func set_rarity(new_rarity:Item.ItemRarity) -> void:
	if new_rarity == Item.ItemRarity.GOD_ROLL: max_affixes = 3
	
	while self.item_rarity != new_rarity:
		add_affix()

func add_affix() -> void:
	var pref_amount:int = len(prefixes)
	var suf_amount:int = len(suffixes)
	
	if pref_amount == max_affixes && suf_amount == max_affixes:
		return
	
	if pref_amount > suf_amount: add_suffix()
	elif suf_amount > pref_amount: add_prefix()
	else:
		var which:int = randi_range(1,2)
		if which == 1: add_prefix()
		else: add_suffix()
	
	var affixes_amount:int = len(prefixes) + len(suffixes)
	self.item_rarity = RARITY_MAP[affixes_amount]

func add_prefix() -> void:
	var number:int = randi_range(0, len(prefix_funcs)-1)
	prefix_funcs[number].call()
	
	var new_affix:Affix = prefixes.back()
	new_affix.affix_generator = prefix_funcs[number]
	
	for key:String in aff_funcs.keys():
		if aff_funcs[key] == prefix_funcs[number]:
			new_affix.generator_key = key
	
	prefix_funcs.remove_at(number)
	
	item_stats_changed.emit()
	
func add_suffix() -> void:
	var number:int = randi_range(0, len(suffix_funcs)-1)
	suffix_funcs[number].call()
	
	var new_affix:Affix = suffixes.back()
	new_affix.affix_generator = suffix_funcs[number]
	
	for key:String in aff_funcs.keys():
		if aff_funcs[key] == suffix_funcs[number]:
			new_affix.generator_key = key
	
	suffix_funcs.remove_at(number)
	
	item_stats_changed.emit()

func remove_affix(aff:Affix) -> void:
	if aff in prefixes:
		prefixes.erase(aff)
		prefix_funcs.push_back(aff.affix_generator)
	else:
		suffixes.erase(aff)
		suffix_funcs.push_back(aff.affix_generator)
	
	var aff_amount:int = suffixes.size() + prefixes.size()
	self.item_rarity = RARITY_MAP[aff_amount]
	
	item_stats_changed.emit()

func save_to_data() -> Dictionary:
	var prefix_data = []
	for pref:Affix in prefixes: prefix_data.push_back(pref.get_save_data())
	
	var suffix_data = []
	for suf:Affix in suffixes: suffix_data.push_back(suf.get_save_data())
	
	var equipment_data:Dictionary = {
		"equipment_type": "res://Tile-RPG/Items/equipment.gd",
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefix_data,
		"suffixes": suffix_data,
		"item_rarity": item_rarity,
		"inventory_image": inventory_image.resource_path,
		"item_value": item_value,
		"item_name": item_name,
	}

	return equipment_data

func _handle_used_aff_generators(loaded_affix:Affix) -> void:
	var key:String = loaded_affix.generator_key
	var used_func:Callable = aff_funcs[key]
	loaded_affix.affix_generator = used_func
	
	if key[0] == "p": prefix_funcs.erase(used_func)
	else: suffix_funcs.erase(used_func)

func _load_affixes(save_data:Dictionary) -> void:
	for aff_data:Dictionary in save_data["prefixes"]:
		var new_pref:Affix = Affix.new()
		new_pref.load_from_data(aff_data)
		prefixes.push_back(new_pref)
		_handle_used_aff_generators(new_pref)
	
	for aff_data:Dictionary in save_data["suffixes"]:
		var new_suf:Affix = Affix.new()
		new_suf.load_from_data(aff_data)
		suffixes.push_back(new_suf)
		_handle_used_aff_generators(new_suf)

func load_from_data(save_data:Dictionary) -> void:
	_load_affixes(save_data)

	self.item_level = save_data["item_level"]
	self.equipment_slot = save_data["equipment_slot"]
	self.item_rarity = save_data["item_rarity"]
	self.inventory_image = load(save_data["inventory_image"])
	self.item_value = save_data["item_value"]
	self.item_name = save_data["item_name"]
	
#Affixes for all types of equipment
func _mainstat_suffix() -> void:
	const NAMES := {
		Stats.MainStat.AGILITY: "Ferocity",
		Stats.MainStat.ENDURANCE: "Hardiness",
		Stats.MainStat.LUCK: "Fortune",
		Stats.MainStat.MIGHT: "Brawn",
		Stats.MainStat.MYSTIC: "Wisdom",
		Stats.MainStat.SKILL: "Adeptness",
		Stats.MainStat.VALOR: "Grace"
	}
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level)
	var stat_to_increase:Stats.MainStat = NAMES.keys().pick_random()
	
	new_suffix.type_increase = stat_to_increase
	new_suffix.increase_amount = amount
	new_suffix.affix_name = NAMES[stat_to_increase]
	new_suffix.affix_text = "+" + str(amount) + " " + EnumStrings.MAIN_STAT_NAMES[stat_to_increase]
	
	suffixes.push_back(new_suffix)

func _health_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level * 2)
	new_prefix.type_increase = Stats.ResourceStat.MAX_HP
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Goliath's"
	new_prefix.affix_text = "+" + str(amount) + " Max Health"
	
	prefixes.push_back(new_prefix)
	
func _dmg_percent_prefix() -> void:
	const NAMES := {
		Stats.DmgIncreases.PHYSICAL: "Brute's",
		Stats.DmgIncreases.MYSTICAL: "Scholar's",
		Stats.DmgIncreases.LIGHTNING: "Sparker's",
		Stats.DmgIncreases.FIRE: "Pyromaniac's",
		Stats.DmgIncreases.FROST: "Cryomancer's",
		Stats.DmgIncreases.TOXIC: "Poisoner's"
	}
	var new_prefix:Affix = Affix.new()
	var amount:int = randi_range(1, item_level*2)
	var stat_to_increase:Stats.DmgIncreases = NAMES.keys().pick_random()
	
	new_prefix.type_increase = stat_to_increase
	new_prefix.increase_amount = amount
	new_prefix.affix_name = NAMES[stat_to_increase]
	new_prefix.affix_text = "+" + str(amount) + "% to " + EnumStrings.DMG_TYPE_NAMES[stat_to_increase] + " damage"
	
	prefixes.push_back(new_prefix)
	
func _thorns_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, item_level + 2)
	new_prefix.type_increase = Stats.SecondaryStat.THORNS
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Spiky"
	new_prefix.affix_text = "+" + str(amount) + " Thorns"
	
	prefixes.push_back(new_prefix)
	
func _spell_crit_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(5, item_level + 8)
	new_prefix.type_increase = Stats.SecondaryStat.SPELL_CRIT_CHANCE
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Occult"
	new_prefix.affix_text = "+" + str(amount) +"% Spell Crit Chance"
	
	prefixes.push_back(new_prefix)
	
func _spell_base_crit_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	
	var amount:int = randi_range(1, 5)
	new_prefix.type_increase = Stats.SecondaryStat.SPELL_BASE_CRIT
	new_prefix.increase_amount = amount
	new_prefix.affix_name = "Calamity"
	new_prefix.affix_text = "+" + str(amount) +"% Base Spell Crit Chance"
	
	prefixes.push_back(new_prefix)
	
func _weapon_dmg_prefix() -> void:
	var new_prefix:Affix = Affix.new()
	const NAMES = {
	Stats.DmgIncreases.SWORD:"Swordmaster",
	Stats.DmgIncreases.STAFF: "Staffmaster",
	Stats.DmgIncreases.AXE: "Axemaster",
	Stats.DmgIncreases.MACE: "Macemaster",
	Stats.DmgIncreases.DAGGER: "Daggermaster",
	Stats.DmgIncreases.BOW: "Bowmaster"
	}
	
	var stat_to_increase = NAMES.keys().pick_random()
	
	var amount:int = randi_range(5,item_level + 5)
	new_prefix.type_increase = stat_to_increase
	new_prefix.increase_amount = amount
	new_prefix.affix_name = NAMES[stat_to_increase]
	new_prefix.affix_text = "+" + str(amount) +"% Damage with "+ EnumStrings.DMG_TYPE_NAMES[stat_to_increase] + "s"
	
	prefixes.push_back(new_prefix)

func _resistance_suffix():
	const NAMES = {
		Stats.DmgType.PHYSICAL: "Hardening",
		Stats.DmgType.MYSTICAL: "Protection",
		Stats.DmgType.TOXIC: "Curing",
		Stats.DmgType.FROST: "Warmth",
		Stats.DmgType.FIRE: "Dousing",
		Stats.DmgType.LIGHTNING: "Absorbtion",
	}
	var new_suffix:Affix = Affix.new()
	
	var amount:int = randi_range(3, item_level + 5)
	var stat_to_increase = NAMES.keys().pick_random()
	
	new_suffix.type_increase = stat_to_increase
	new_suffix.increase_amount = amount
	new_suffix.affix_name = NAMES[stat_to_increase]
	new_suffix.affix_text = "+" + str(amount) + "% " + EnumStrings.RES_NAMES[stat_to_increase] + " resistance"
	
	suffixes.push_back(new_suffix)
