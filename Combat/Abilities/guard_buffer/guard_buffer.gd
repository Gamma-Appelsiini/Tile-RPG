extends Ability
class_name GuardBuffer

const GUARD_STATUS := preload("uid://dbu2tcjw1ihgh")
const GENERIC_BUFF_EFFECT := preload("uid://b8xk37t3i1ps4")

#Overrided
func use_ability_on_target_character(target:GameCharacter) -> void:
	var guard_status:GuardStatus = GUARD_STATUS.instantiate()
	var buff_duration:int = 1 + int(ability_owner.stat_handler.get_stat_amount(Stats.MainStat.VALOR) / 10.0)
	
	guard_status.max_duration = buff_duration
	target.status_handler.add_status(guard_status)
	
	var beffect:GenericBuff = GENERIC_BUFF_EFFECT.instantiate()
	beffect.set_color(Color(EnumStrings.MAIN_STAT_COLORS[Stats.MainStat.VALOR]))
	target.add_child(beffect)
	
	#TODO animate
	ability_finished.emit()
