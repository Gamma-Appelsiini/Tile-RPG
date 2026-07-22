extends Ability
class_name BasicAttack

const ARROW_PROJECTILE := preload("uid://vyagdu7xmhu3")
const ARROW_MODEL := preload("uid://bu2olcu1uujmx")

func use_ability_on_target_character(target:GameCharacter, check_usability:bool = true) -> void:
	var new_attack:Attack = get_attack()
	
	if check_usability:
		if !_can_use_ability(target):
			ability_finished.emit()
			return
		_use_resources()
		
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	if self.use_animation == CharacterModelHandler.CharAnimation.ATTACK_BOW:
		await _handle_bow_animation(target)
	else: await _set_and_wait_hit_animation()
	
	_spawn_hit_effect(target)
	AttackHandler.use_attack_on_char(target, new_attack)
	
	await ability_owner.char_model_handler.animation_player.animation_finished
	ability_finished.emit()

func _set_and_wait_hit_animation() -> void:
	ability_owner.char_model_handler.play_animation(self.use_animation)
	await ability_owner.get_tree().create_timer(self.hit_delay).timeout

func _animate_bow_string() -> void:
	var bow_model:ItemModel = ability_owner.equipment_handler.main_hand_model
	bow_model.draw_bow_string(ATTACK_DELAYS[CharacterModelHandler.CharAnimation.ATTACK_BOW])

func _handle_bow_animation(target:GameCharacter) -> void:
	var arrow_model:Node3D = ARROW_MODEL.instantiate()
	var new_arrow:Projectile = ARROW_PROJECTILE.instantiate()
	
	ability_owner.char_model_handler.off_hand_node.add_child(arrow_model)
	ability_owner.char_model_handler.off_hand_node.add_child(new_arrow)
	new_arrow.hide()
	
	_animate_bow_string()
	await _set_and_wait_hit_animation()
	
	var y_offset:float = target.heigth_node.position.y - (target.heigth_node.position.y / 3)
	arrow_model.queue_free()
	new_arrow.show()
	new_arrow.shoot_at_pos(target.global_position + Vector3(0,y_offset,0) )
	await new_arrow.hit_target

#Overrided
func get_range() -> int:
	var weapon:Weapon = ability_owner.equipment_handler.equipped_items[Equipment.EquipmentSlot.MAIN_HAND]
	_set_ability_weapon_range(weapon)
	
	return ability_range

#Overrided
func get_attack(is_min:bool = false, is_max:bool = false) -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack, is_min, is_max)
	new_attack.calculate_weapon_damage_increase()
	new_attack.apply_damage_increases()
	new_attack.calculate_crit()
	
	return new_attack
