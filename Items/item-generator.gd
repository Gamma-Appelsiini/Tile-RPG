class_name ItemGenerator

#Items are sorted by tiers
const SWORDS:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_sword.tres")}

const AXES:Dictionary[int,Weapon] = {0: preload("res://Tile-RPG/Items/Resources/basic_sword.tres")}

const SHIELDS:Dictionary[int,Shield] = {0: preload("res://Tile-RPG/Items/Resources/basic_shield.tres")}

const ALL_DICTS:Array[Dictionary] = [SWORDS,AXES,SHIELDS]

const WEIGHTED_RARITIES:Dictionary[Item.ItemRarity,int] = {Item.ItemRarity.POOR : 750,
	Item.ItemRarity.COMMON : 250,
	Item.ItemRarity.RARE : 500,
	Item.ItemRarity.EPIC : 250,
	Item.ItemRarity.LEGENDARY : 100,
	Item.ItemRarity.GOD_ROLL : 10}

func get_random_equipment(ilvl:int = 1, max_tier:int = 0, item_rarity:Item.ItemRarity = Item.ItemRarity.POOR) -> Equipment:
	var new_equipment:Equipment = null
	
	var possible_equipment:Array[Equipment] = []
	for dict:Dictionary in ALL_DICTS:
		for tier:int in dict.keys():
			if max_tier >= tier: possible_equipment.push_back(dict[tier])
			
	new_equipment = possible_equipment.pick_random().duplicate()
	new_equipment.item_level = ilvl
	new_equipment.set_rarity(item_rarity)
	
	return new_equipment

func get_random_rarity_equipment(ilvl:int = 1, max_tier:int = 0) -> Equipment:
	var new_equipment:Equipment = null
	var new_rarity:Item.ItemRarity
	
	var weighted_sum:int = 0
	for amount:int in WEIGHTED_RARITIES.values():
		weighted_sum += amount
		
	var rarity_sum:int = randi_range(0,weighted_sum)
	
	for rarity:Item.ItemRarity in WEIGHTED_RARITIES.keys():
		if  WEIGHTED_RARITIES[rarity] >= rarity_sum: new_rarity = rarity
	
	new_equipment = get_random_equipment(ilvl,max_tier,new_rarity)
	
	return new_equipment
