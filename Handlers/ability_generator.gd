class_name AbilityGenerator

const ATTACK_ABILITIES:Dictionary[int, Array] = {
	0: [],
}

const SPELL_ABILITIES:Dictionary[int, Array] = {
	0: ["res://Tile-RPG/Combat/Abilities/fireball/fireball.tscn", "res://Tile-RPG/Combat/Abilities/ice_bolt/ice_bolt.tscn", "res://Tile-RPG/Combat/Abilities/SkyHammer/sky_hammer.tscn"],
}

const SUPPORT_ABILITIES:Dictionary[int, Array] = {
	0: ["res://Tile-RPG/Combat/Abilities/cure_wounds/cure_wounds.tscn", "res://Tile-RPG/Combat/Abilities/evasion_buffer/evasion_buffer.tscn"],
}

const MOVEMENT_ABILITIES:Dictionary[int, Array] = {
	0: [],
}

const ALL_DICTS:Array[Dictionary] = [ATTACK_ABILITIES, SPELL_ABILITIES, SUPPORT_ABILITIES, MOVEMENT_ABILITIES]

static func get_random_ability(max_tier:int = -1) -> Ability:
	var new_ability:Ability
	var possible_ability_paths:Array[String] = []
	
	for dict:Dictionary[int, Array] in ALL_DICTS:
		for tier:int in dict.keys():
			if max_tier == -1 or tier <= max_tier:
				for ability_path:String in dict[tier]: possible_ability_paths.push_back(ability_path)
				
	new_ability = load(possible_ability_paths.pick_random()).instantiate()
	
	return new_ability

static func get_random_ability_path(max_tier:int = -1) -> String:
	var new_ability_path:String = ""
	var possible_ability_paths:Array[String] = []
	
	for dict:Dictionary[int, Array] in ALL_DICTS:
		for tier:int in dict.keys():
			if max_tier == -1 or tier <= max_tier:
				for ability_path:String in dict[tier]: possible_ability_paths.push_back(ability_path)
				
	new_ability_path = possible_ability_paths.pick_random()
	
	return new_ability_path

static func get_ability_type_from_path(path:String) -> Stats.MainStat:
	for path_array:Array in ATTACK_ABILITIES.values():
		if path_array.has(path): return Stats.MainStat.MIGHT
		
	for path_array:Array in SPELL_ABILITIES.values():
		if path_array.has(path): return Stats.MainStat.MYSTIC
		
	for path_array:Array in SUPPORT_ABILITIES.values():
		if path_array.has(path): return Stats.MainStat.VALOR
		
	for path_array:Array in MOVEMENT_ABILITIES.values():
		if path_array.has(path): return Stats.MainStat.AGILITY
	
	return Stats.MainStat.ENDURANCE
