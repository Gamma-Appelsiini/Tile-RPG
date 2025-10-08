class_name Attack

enum ATTACK_TAG {MELEE, RANGED, SPELL, AOE, SINGLE_TARGET, HIT, DOT, UNEVADEABLE, NO_RETALIATION}

var attacker:GameCharacter = null
var damages:Dictionary[Stats.DmgType,int] = {}
var main_damage_type:Stats.DmgType = Stats.DmgType.PHYSICAL
var tags: Array[ATTACK_TAG] = []
var crit:bool = false

var base_crit_chance: int = 5
var crit_multiplier:int = 100

func calculate_crit() -> void:
	var crit_chance:int = base_crit_chance
	var final_crit_multiplier:float = crit_multiplier
	
	final_crit_multiplier += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_MULTIPLIER]
	if tags.has(ATTACK_TAG.SPELL):
		crit_chance += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_BASE_CRIT]
		final_crit_multiplier += attacker.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_CRIT_MULTIPLIER]
	
	crit_chance = int(crit_chance * (attacker.stat_handler.secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_CHANCE] / 100.0) )
	if crit_chance > randi_range(1,100):
		damages[main_damage_type] = int(damages[main_damage_type] * final_crit_multiplier / 100)
		crit = true
