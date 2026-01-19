class_name ItemGenerator

enum LOOT_TYPE {
	RANDOM, SWORD, AXE, STAFF, SHIELD, MACE, BOW, RING, AMULET, BODY_ARMOR, HELMET, BELT, DAGGER,
	BOOTS, GLOVES,
	}

#Items are sorted by tiers
const SWORDS:Dictionary[int,Weapon] = {
	0: preload("res://Tile-RPG/Items/Resources/basic_sword.tres"),
	1: preload("res://Tile-RPG/Items/Resources/basic_2h_sword.tres"),
	}

const AXES:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_axe.tres")}

const STAFFS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_staff.tres")}

const SHIELDS:Dictionary[int,Shield] = {0: preload("res://Tile-RPG/Items/Resources/basic_shield.tres")}

const MACES:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_mace.tres")}

const BOWS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_bow.tres")}

const RINGS:Dictionary[int,Jewellery] = {0: preload("res://Tile-RPG/Items/Resources/basic_ring.tres")}

const AMULETS:Dictionary[int,Jewellery] = {0: preload("res://Tile-RPG/Items/Resources/basic_amulet.tres")}

const ARMOR_BODIES:Dictionary[int,BodyArmor] = {0: preload("res://Tile-RPG/Items/Resources/basic_armor_body.tres")}

const BODY_ARMORS:Dictionary[Stats.Defence, Dictionary] = {Stats.Defence.ARMOR: ARMOR_BODIES,}

const ARMOR_HELMETS:Dictionary[int,Helmet] = {0: preload("res://Tile-RPG/Items/Resources/basic_armor_helmet.tres")}

const HELMETS:Dictionary[Stats.Defence, Dictionary] = {Stats.Defence.ARMOR: ARMOR_HELMETS,}

const BELTS:Dictionary[int,Belt] = {0: preload("res://Tile-RPG/Items/Resources/basic_belt.tres")}

const DAGGERS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_dagger.tres")}

const EVASION_BOOTS:Dictionary[int,Boots] = {0: preload("res://Tile-RPG/Items/Resources/basic_evasion_boots.tres")}

const BOOTS:Dictionary[Stats.Defence, Dictionary] = {Stats.Defence.EVASION: EVASION_BOOTS,}

const EVASION_GLOVES:Dictionary[int,Gloves] = {0: preload("res://Tile-RPG/Items/Resources/basic_evasion_gloves.tres")}

const GLOVES:Dictionary[Stats.Defence, Dictionary] = {Stats.Defence.EVASION: EVASION_GLOVES,}

const ALL_DICTS:Dictionary[LOOT_TYPE, Dictionary] = {
	LOOT_TYPE.SWORD: SWORDS,
	LOOT_TYPE.AXE: AXES,
	LOOT_TYPE.STAFF: STAFFS,
	LOOT_TYPE.SHIELD: SHIELDS,
	LOOT_TYPE.MACE: MACES,
	LOOT_TYPE.BOW: BOWS,
	LOOT_TYPE.RING: RINGS,
	LOOT_TYPE.AMULET: AMULETS,
	LOOT_TYPE.BODY_ARMOR: BODY_ARMORS,
	LOOT_TYPE.HELMET: HELMETS,
	LOOT_TYPE.BELT: BELTS,
	LOOT_TYPE.DAGGER: DAGGERS,
	LOOT_TYPE.BOOTS: BOOTS,
	LOOT_TYPE.GLOVES: GLOVES,
	
}

const MULTIPLE_TYPES:Array[LOOT_TYPE] = [LOOT_TYPE.BODY_ARMOR, LOOT_TYPE.BOOTS, LOOT_TYPE.HELMET, LOOT_TYPE.GLOVES]

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

static func _get_armor_equipment(loot_type:LOOT_TYPE, max_tier:int) -> Array[Equipment]:
	var possible_equipment:Array[Equipment] = []
	var dict_of_all_armors_of_type:Dictionary[Stats.Defence, Dictionary] = ALL_DICTS[loot_type]
	
	for armor_dict:Dictionary in dict_of_all_armors_of_type.values():
		for tier:int in armor_dict.keys():
			if max_tier >= tier: possible_equipment.push_back(armor_dict[tier])
	
	return possible_equipment

static func _get_random_equipment(max_tier:int) -> Array[Equipment]:
	var possible_equipment:Array[Equipment] = []

	for loot_type:LOOT_TYPE in ALL_DICTS.keys():
		if MULTIPLE_TYPES.has(loot_type): continue 
		
		for tier:int in ALL_DICTS[loot_type].keys():
			if max_tier >= tier: possible_equipment.push_back(ALL_DICTS[loot_type][tier])
	
	for loot_type:LOOT_TYPE in MULTIPLE_TYPES:
		possible_equipment += _get_armor_equipment(loot_type, max_tier)
	
	return possible_equipment

static func _choose_equipment_type(loot_type:LOOT_TYPE, ilvl:int, max_tier:int, item_rarity:Item.ItemRarity) -> Equipment:
	if MULTIPLE_TYPES.has(loot_type): pass
	
	var new_equipment:Equipment = null
	var possible_equipment:Array[Equipment] = []
	
	if loot_type == LOOT_TYPE.RANDOM: possible_equipment = _get_random_equipment(max_tier)
	elif MULTIPLE_TYPES.has(loot_type): possible_equipment = _get_armor_equipment(loot_type, max_tier)
	else:
		var loot_dict:Dictionary = ALL_DICTS[loot_type]
		for tier:int in loot_dict.keys():
			if max_tier >= tier: possible_equipment.push_back(loot_dict[tier])
	
	new_equipment = possible_equipment.pick_random()
	new_equipment.resource_local_to_scene = true
	#Deep duplication to create true duplicate dicts etc.
	new_equipment = new_equipment.duplicate(true)
	
	new_equipment.item_level = ilvl
	new_equipment.original_item_level = ilvl
	new_equipment.set_rarity(item_rarity)
	
	return new_equipment
