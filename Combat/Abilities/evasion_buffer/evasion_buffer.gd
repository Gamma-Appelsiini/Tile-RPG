extends Ability
class_name EvasionBuffer

const EVASION_STATUS := preload("uid://ctryr6cqir6ne")
const GENERIC_BUFF_EFFECT := preload("uid://b8xk37t3i1ps4")

var evasion_amount:int = 0
var status_duration:int = 0

#Overrided
func use_ability_on_target_character(target:GameCharacter) -> void:
	var evasion_status:EvasionBuff = EVASION_STATUS.instantiate()
	status_duration = 2
	evasion_amount = 5 + ability_owner.stat_handler.get_stat_amount(Stats.MainStat.AGILITY) * 3 + ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) * 2
	
	evasion_status.set_evasion_stats(evasion_amount, status_duration)
	target.status_handler.add_status(evasion_status)
	
	var beffect:GenericBuff = GENERIC_BUFF_EFFECT.instantiate()
	beffect.set_color(Color(EnumStrings.MAIN_STAT_COLORS[Stats.MainStat.AGILITY]))
	target.add_child(beffect)
	
	#TODO animate
	ability_finished.emit()

#Overrided
func get_range() -> int:
	var range_increase:int = 0
	if ability_tags.has(ABILITY_TAG.SPELL): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_RANGE]
	if ability_tags.has(ABILITY_TAG.RANGED): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.BOW_RANGE]
	return ability_range + int(ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MYSTIC) / 5.0) + range_increase
