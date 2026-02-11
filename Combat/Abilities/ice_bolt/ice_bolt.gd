extends Ability
class_name IceBolt

const FREEZE_STATUS := preload("uid://6enlcywwmbt7")

func use_ability_on_target_character(target:GameCharacter) -> void:
	#var new_attack:Attack = _create_attack()
	if !_can_use_ability(target): return
	
	#_use_resources()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	_freeze_target(target)
	_spawn_hit_effect(target)
	#AttackHandler.use_attack_on_char(target, new_attack)
	
	#await ability_owner.char_model_handler.animation_player.animation_finished
	ability_finished.emit()

func _freeze_target(target:GameCharacter) -> void:
	var new_freeze:Status = FREEZE_STATUS.instantiate()
	
	target.status_handler.add_status(new_freeze)
