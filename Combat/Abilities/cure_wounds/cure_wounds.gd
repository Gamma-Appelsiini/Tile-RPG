extends Ability
class_name CureWounds

const HEAL_EFFECT := preload("uid://bftoty805070m")

func use_ability_on_target_character(target:GameCharacter) -> void:
	if !_can_use_ability(target):
		ability_finished.emit()
		return
	
	_use_resources()
	#TODO animate caster
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	var heal_effect:Effect = HEAL_EFFECT.instantiate()
	target.add_child(heal_effect)
	var heal_amount: int = ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) + int(ability_owner.stat_handler.get_stat_amount(Stats.MainStat.VALOR) / 2.0 )
	
	target.stat_handler.update_stat(Stats.ResourceStat.CURRENT_HP, heal_amount)
	GlobalSignals.show_damage_number.emit(heal_amount, target)
	_spawn_hit_effect(target)
	
	await get_tree().create_timer(0.3).timeout
	ability_finished.emit()
