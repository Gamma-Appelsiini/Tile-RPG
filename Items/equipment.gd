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

const RARITY_MAP:Dictionary[int,Item.ItemRarity] = {0: Item.ItemRarity.POOR,
	1: Item.ItemRarity.COMMON,
	2: Item.ItemRarity.RARE,
	3: Item.ItemRarity.EPIC,
	4: Item.ItemRarity.LEGENDARY,
	5: Item.ItemRarity.GOD_ROLL,
	6: Item.ItemRarity.GOD_ROLL,}

func add_prefix() -> void:
	var number:int = randi_range(0, len(prefix_funcs)-1)
	prefix_funcs[number].call()
	prefix_funcs.remove_at(number)
	
	item_stats_changed.emit()
	
func add_suffix() -> void:
	var number:int = randi_range(0, len(suffix_funcs)-1)
	suffix_funcs[number].call()
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

func save_to_data() -> void:
	var equipment_data:Dictionary = {
		"equipment_slot": equipment_slot,
		"item_level": item_level,
		"prefixes": prefixes,
		"suffixes": suffixes,
		"item_rarity": item_rarity
	}

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
	var stat_to_increase:Stats.MainStat = NAMES.keys()[randi() % Stats.MainStat.values().size()-1]
	
	new_suffix.type_increase = stat_to_increase
	new_suffix.increase_amount = amount
	new_suffix.affix_name = NAMES[stat_to_increase]
	new_suffix.affix_text = "+" + str(amount) + " " + EnumStrings.main_stat_names[stat_to_increase]
	
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
	var stat_to_increase:Stats.DmgIncreases = NAMES.keys()[randi() % Stats.DmgIncreases.values().size()-1]
	
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
	
	var stat_to_increase = NAMES.keys()[randi() % NAMES.values().size()-1]
	
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
	var stat_to_increase = NAMES.keys()[randi() % NAMES.values().size()-1]
	
	new_suffix.type_increase = stat_to_increase
	new_suffix.increase_amount = amount
	new_suffix.affix_name = NAMES[stat_to_increase]
	new_suffix.affix_text = "+" + str(amount) + "% " + EnumStrings.RES_NAMES[stat_to_increase] + " resistance"
	
	suffixes.push_back(new_suffix)
