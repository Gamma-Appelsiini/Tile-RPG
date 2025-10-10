extends Ability
class_name BasicAttack

func use_ability_on_target_character(target:GameCharacter) -> void:
	var new_attack:Attack = _create_attack()
	self.target_char = target
	
	if !_is_target_valid(target): return
	if !_is_in_range(): return
	if !_is_enough_resources(): return
	
	_use_resources()
	#TODO animate attacker
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	AttackHandler.use_attack_on_char(target, new_attack)

func _create_attack() -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack)
	new_attack.calculate_weapon_damage_increase()
	new_attack.calculate_crit()
	
	return new_attack
