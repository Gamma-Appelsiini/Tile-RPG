class_name ItemGenerator

enum LOOT_TYPE {RANDOM, SWORD, AXE, STAFF, SHIELD, MACE}

#Items are sorted by tiers
const SWORDS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_sword.tres")}

const AXES:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_axe.tres")}

const STAFFS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_staff.tres")}

const SHIELDS:Dictionary[int,Shield] = {0: preload("res://Tile-RPG/Items/Resources/basic_shield.tres")}

const MACES:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_mace.tres")}

const ALL_DICTS:Dictionary[LOOT_TYPE, Dictionary] = {
	LOOT_TYPE.SWORD: SWORDS,
	LOOT_TYPE.AXE: AXES,
	LOOT_TYPE.STAFF: STAFFS,
	LOOT_TYPE.SHIELD: SHIELDS,
	LOOT_TYPE.MACE: MACES,
}

const WEIGHTED_RARITIES:Dictionary[Item.ItemRarity,int] = {Item.ItemRarity.POOR : 750,
	Item.ItemRarity.COMMON : 250,
	Item.ItemRarity.RARE : 500,
	Item.ItemRarity.EPIC : 250,
	Item.ItemRarity.LEGENDARY : 100,
	Item.ItemRarity.GOD_ROLL : 10}

static func get_equipment(loot_type:LOOT_TYPE = LOOT_TYPE.RANDOM, ilvl:int = 1, max_tier:int = 0, item_rarity:Item.ItemRarity = Item.ItemRarity.POOR) -> Equipment:
	var new_equipment:Equipment = null
	if item_rarity == Item.ItemRarity.RANDOM: item_rarity = _get_random_rarity()
	
	new_equipment = _choose_equipment_type(loot_type,ilvl,max_tier,item_rarity)
	
	return new_equipment

static func _get_random_rarity() -> Item.ItemRarity:
	var new_rarity:Item.ItemRarity = Item.ItemRarity.POOR
	
	var weighted_sum:int = 0
	for amount:int in WEIGHTED_RARITIES.values():
		weighted_sum += amount
		
	var rarity_sum:int = randi_range(0,weighted_sum)
	
	for rarity:Item.ItemRarity in WEIGHTED_RARITIES.keys():
		if  WEIGHTED_RARITIES[rarity] >= rarity_sum: new_rarity = rarity
	
	return new_rarity

static func _choose_equipment_type(loot_type:LOOT_TYPE, ilvl:int, max_tier:int, item_rarity:Item.ItemRarity) -> Equipment:
	var new_equipment:Equipment = null
	var possible_equipment:Array[Equipment] = []
	
	if loot_type == LOOT_TYPE.RANDOM:
		for dict:Dictionary in ALL_DICTS.values():
			for tier:int in dict.keys():
				if max_tier >= tier: possible_equipment.push_back(dict[tier])
	else:
		var loot_dict:Dictionary = ALL_DICTS[loot_type]
		for tier:int in loot_dict.keys():
			if max_tier >= tier: possible_equipment.push_back(loot_dict[tier])
	
	new_equipment = possible_equipment.pick_random().duplicate()
	new_equipment.item_level = ilvl
	new_equipment.original_item_level = ilvl
	new_equipment.set_rarity(item_rarity)
	
	return new_equipment
