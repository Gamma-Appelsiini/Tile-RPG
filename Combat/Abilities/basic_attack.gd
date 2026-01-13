extends Ability
class_name BasicAttack

func use_ability_on_target_character(target:GameCharacter) -> void:
	var new_attack:Attack = _create_attack()
	if !_can_use_ability(target): return
	
	_use_resources()
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(self.use_animation)
	await ability_owner.get_tree().create_timer(self.hit_delay).timeout
	
	_spawn_hit_effect(target)
	AttackHandler.use_attack_on_char(target, new_attack)
	
	await ability_owner.char_model_handler.animation_player.animation_finished
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
	
	var range_increase:int = 0
	if weapon:
		if weapon.weapon_type == Weapon.WeaponType.BOW: range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.BOW_RANGE]
	
	return ability_range + range_increase

#Overrided
func get_dmg() -> Dictionary[Stats.DmgType,int]:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack)
	new_attack.calculate_weapon_damage_increase()
	
	return new_attack.damages
