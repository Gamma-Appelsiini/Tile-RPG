extends Ability
class_name BasicAttack

func use_ability_on_target_character(target:GameCharacter) -> void:
	var new_attack:Attack = _create_attack()
	if !_can_use_ability(target): return
	
	_use_resources()
	#TODO animate attacker
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	_spawn_hit_effect(target)
	AttackHandler.use_attack_on_char(target, new_attack)
	
	#await get_tree().create_timer(0.3).timeout
	ability_finished.emit()

func _create_attack() -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack)
	new_attack.calculate_weapon_damage_increase()
	new_attack.calculate_crit()
	
	return new_attack

#Overrided
func get_range() -> int:
	var weapon:Weapon = ability_owner.equipment_handler.equipped_items[Equipment.EquipmentSlot.MAIN_HAND]
	_set_ability_weapon_range(weapon)
	
	return ability_range

#Overrided
func get_dmg() -> Dictionary[Stats.DmgType,int]:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack)
	new_attack.calculate_weapon_damage_increase()
	
	return new_attack.damages
