class_name Attack

#enum ATTACK_TAG {MELEE, RANGED, SPELL, AOE, SINGLE_TARGET, HIT, DOT, UNEVADEABLE, NO_RETALIATION, WEAPON}

var attacker:GameCharacter = null
var damages:Dictionary[Stats.DmgType,int] = {}
var defence_penetrations:Dictionary[Stats.Defence,int] = {
	Stats.Defence.ARMOR: 0,
	Stats.Defence.EVASION: 0,
	Stats.Defence.BLOCK: 0,
	Stats.Defence.SPELL_BLOCK: 0
}
var main_damage_type:Stats.DmgType = Stats.DmgType.PHYSICAL
var ability_tags:Array[Ability.ABILITY_TAG] = []
var crit:bool = false

var base_crit_chance: int = 5
var base_crit_multiplier:int = 100

func set_tags(new_tags:Array[Ability.ABILITY_TAG]) -> void:
	ability_tags = new_tags

func calculate_crit() -> void:
	var crit_chance:int = base_crit_chance
	var final_crit_multiplier:float = base_crit_multiplier
	
	final_crit_multiplier += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_MULTIPLIER]
	if ability_tags.has(Ability.ABILITY_TAG.SPELL):
		crit_chance += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_BASE_CRIT]
		final_crit_multiplier += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_CRIT_MULTIPLIER]
	
	crit_chance = int(crit_chance * (attacker.stat_handler.secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_CHANCE] / 100.0) )
	if crit_chance > randi_range(1,100):
		damages[main_damage_type] = int(damages[main_damage_type] * final_crit_multiplier / 100)
		crit = true

func calculate_weapon_damage_increase() -> void:
	if !ability_tags.has(Ability.ABILITY_TAG.WEAPON): return
	var weapon:Weapon = attacker.equipment_handler.equipped_items[Equipment.EquipmentSlot.MAIN_HAND]
	if weapon == null: return
	
	#Weapon enums are 450 lower than corresponding dmg increases
	if attacker.stat_handler.dmg_increases.has(weapon.weapon_type + 450):
		var dmg_multiplier:float = 1.0 + (attacker.stat_handler.dmg_increases[weapon.weapon_type + 50] / 100.0)
		
		for dmg_type in damages.keys():
			damages[dmg_type] = int(damages[dmg_type] * dmg_multiplier)
