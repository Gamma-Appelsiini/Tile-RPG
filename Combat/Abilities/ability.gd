extends Node
class_name Ability

signal ability_finished
signal insufficient_ap
signal insufficient_spirit
signal ability_on_cooldown
signal cooldown_changed

enum TARGET_TYPE {TILE, GAME_CHARACTER, NONE}
enum ABILITY_TAG {SINGLE_TARGET, AOE, MELEE, RANGED, SPELL, HIT, DOT, UNEVADEABLE, NO_RETALIATION, WEAPON}
enum CHARACTER_TYPE {ALLY, ENEMY, SELF}
enum ANIMATION_TYPE {MELEE, SPELL, RANGED}

@export var animation_type:ANIMATION_TYPE = ANIMATION_TYPE.MELEE
@export var target_type:TARGET_TYPE = TARGET_TYPE.GAME_CHARACTER
@export var usable_on_characters:Array[CHARACTER_TYPE] = []
@export var ability_tags:Array[ABILITY_TAG] = []
@export var ability_icon: Texture = null
@export var ability_name:String = "Default Ability Name"
@export var ability_cooldown: int = 0
@export var ap_cost: int = 1
@export var spirit_cost: int = 0
@export var ability_range: int = 1
@export var ability_aoe: int = 1

var ability_owner:GameCharacter = null
var current_cooldown:int = 0
var ability_description:String = "Default Ability Description"
var target_char:GameCharacter = null
var target_tile:Tile = null

#Override
func get_description() -> String:
	return ability_description

#Override
func use_ability_on_target_character(target:GameCharacter) -> void:
	print(target.name)
	pass

#Override
func use_ability_on_target_tile(target:Tile) -> void:
	print(target.name)
	pass

#Override
func get_dmg() -> Dictionary[Stats.DmgType,int]:
	return {}

#Override
func get_range() -> int:
	return ability_range
	
#Override
func get_aoe() -> int:
	return ability_aoe

#Override
func get_sp_cost() -> int:
	return spirit_cost
	
#Override
func get_cd() -> int:
	return ability_cooldown
	
func _is_target_valid(target:Node) -> bool:
	if target is GameCharacter:
		if self.target_type != TARGET_TYPE.GAME_CHARACTER: return false
		if !usable_on_characters.has(CHARACTER_TYPE.SELF) and target == ability_owner: return false
		#TODO add check to see if target is ally
		#if !usable_on_characters.has(CHARACTER_TYPE.ALLY) and target == ability_owner: return false
		#TODO add check to see if target is enemy
		#if !usable_on_characters.has(CHARACTER_TYPE.ENEMY) and target == ability_owner: return false
	elif target is Tile:
		if self.target_type != TARGET_TYPE.TILE: return false
	
	return true

func _use_resources() -> void:
	ability_owner.stat_handler.update_stat(Stats.ResourceStat.CURRENT_AP, -ap_cost)
	ability_owner.stat_handler.update_stat(Stats.ResourceStat.CURRENT_SPIRIT, -spirit_cost)
	current_cooldown = ability_cooldown
	cooldown_changed.emit()

func _is_enough_resources() -> bool:
	if current_cooldown > 0:
		ability_on_cooldown.emit()
		return false
	elif ap_cost > ability_owner.stat_handler.resources[Stats.ResourceStat.CURRENT_AP]:
		insufficient_ap.emit()
		return false
	elif spirit_cost > ability_owner.stat_handler.resources[Stats.ResourceStat.CURRENT_SPIRIT]:
		insufficient_spirit.emit()
		return false
	
	return true

func _can_use_ability(target:Node) -> bool:
	if target is GameCharacter: target_char = target
	elif target is Tile: target_tile = target
	else: return false
	
	if !_is_enough_resources(): return false
	if !_is_target_valid(target): return false
	if !_is_in_range(): return false
	
	return true

func _is_in_range() -> bool:
	var tile_manager:TileManager = GlobalSignals.current_level.tile_manager
	var ability_user_tile:Tile = tile_manager.char_tiles[ability_owner]
	var distance:int = -1
	
	var range_increase:int = 0
	if ability_tags.has(ABILITY_TAG.SPELL): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_RANGE]
	if ability_tags.has(ABILITY_TAG.RANGED): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.BOW_RANGE]
	
	if target_type == TARGET_TYPE.NONE: return true
	elif target_type == TARGET_TYPE.TILE:
		distance = tile_manager.get_distance_to_tile(ability_user_tile, target_tile)
	else:
		var ability_target_tile:Tile = tile_manager.char_tiles[target_char]
		distance = tile_manager.get_distance_to_tile(ability_user_tile, ability_target_tile)
	
	if distance == -1 or distance > ability_range + range_increase:
		print("Ability not in range")
		return false
	
	return true

func _get_weapon_dmg_to_attack(attack:Attack) -> void:
	var weapon:Weapon = ability_owner.equipment_handler.equipped_items[Equipment.EquipmentSlot.MAIN_HAND]
	_set_ability_weapon_range(weapon)
	
	if weapon == null:
		_unarmed_attack(attack)
		return
	_weapon_attack(attack, weapon)

func _unarmed_attack(attack:Attack) -> void:
	attack.damages[Stats.DmgType.PHYSICAL] = randi_range(1,ability_owner.stat_handler.main_stats[Stats.MainStat.MIGHT])
	attack.ability_tags.push_back(ABILITY_TAG.MELEE)
	attack.ability_tags.push_back(ABILITY_TAG.HIT)
	attack.ability_tags.push_back(ABILITY_TAG.SINGLE_TARGET)
	attack.base_crit_chance = 4 + int(ability_owner.stat_handler.main_stats[Stats.MainStat.AGILITY] * 0.3)
	attack.calculate_crit()

func _set_ability_weapon_range(weapon:Weapon) -> void:
	if weapon == null:
		self.ability_range = 1
		return
	
	self.ability_range = weapon.weapon_stats[Weapon.WeaponStat.RANGE]
	if weapon.weapon_type == Weapon.WeaponType.BOW:
		self.ability_range += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.BOW_RANGE]

func _weapon_attack(attack:Attack, weapon:Weapon) -> void:
	if weapon.weapon_type == Weapon.WeaponType.BOW:
		attack.tags.push_back(ABILITY_TAG.RANGED)
		self.animation_type = ANIMATION_TYPE.RANGED
	else: attack.tags.push_back(ABILITY_TAG.MELEE)
	attack.tags.push_back(ABILITY_TAG.HIT)
	attack.tags.push_back(ABILITY_TAG.WEAPON)
	attack.tags.push_back(ABILITY_TAG.SINGLE_TARGET)
	
	var base_damage:int = randi_range(weapon.weapon_stats[Weapon.WeaponStat.MIN_DMG], weapon.weapon_stats[Weapon.WeaponStat.MAX_DMG])
	var scale_stat_amount:int = ability_owner.stat_handler.main_stats[weapon.scale_stat]
	var multiplier:float = 1.0 + (weapon.weapon_stats[Weapon.WeaponStat.SCALE_AMOUNT] / 100.0 * scale_stat_amount)
	var final_damage:int = int(base_damage * multiplier)
	
	attack.damages[weapon.damage_type] = final_damage
	attack.main_damage_type = weapon.damage_type
	attack.base_crit_chance = weapon.weapon_stats[Weapon.WeaponStat.BASE_CRIT]
	attack.base_crit_multiplier = weapon.weapon_stats[Weapon.WeaponStat.BASE_MULTIPLIER]
	attack.calculate_crit()
