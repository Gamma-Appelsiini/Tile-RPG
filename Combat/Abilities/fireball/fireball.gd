extends Ability
class_name Fireball

const FIREBALL_PROJECTILE := preload("uid://cdqg505uijw8u")

func _shoot_fire_projectile(target:Tile) -> void:
	var y_offset:float = 0.35
	var new_projectile:Projectile = FIREBALL_PROJECTILE.instantiate()
	ability_owner.char_model_handler.off_hand_node.add_child(new_projectile)
	new_projectile.show()
	new_projectile.shoot_at_pos(target.global_position + Vector3(0,y_offset,0) )
	await new_projectile.hit_target

func use_ability_on_target_tile(target:Tile) -> void:
	if !_can_use_ability(target): return
	
	print("Used fireball on tile: ", target)
	_use_resources()
	var tiles_in_aoe:Array[Tile] = GlobalSignals.current_level.tile_manager.get_tiles_in_aoe(target, ability_aoe)
	var fire_attack:Attack = _create_attack()
	
	#TODO animate spell
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.CAST_SPELL)
	
	await _shoot_fire_projectile(target)
	
	for tile:Tile in tiles_in_aoe:
		if tile.occupant:
			AttackHandler.use_attack_on_char(tile.occupant, fire_attack)

func _create_attack() -> Attack:
	var fire_attack:Attack = Attack.new()
	fire_attack.attacker = ability_owner
	fire_attack.damages[Stats.DmgType.FIRE] = 1
	
	return fire_attack
