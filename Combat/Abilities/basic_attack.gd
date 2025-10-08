extends Ability
class_name BasicAttack

func use_ability_on_target_character(target:GameCharacter) -> void:
	if !_is_in_range(): return
	
	var new_attack:Attack = _create_attack()
	
	
	#TODO animate attacker
	AttackHandler.use_attack_on_char(target, new_attack)

func _create_attack() -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	new_attack.tags.push_back(Attack.ATTACK_TAG.HIT)
	
	return new_attack
