extends Ability
class_name Fireball

func use_ability_on_target_tile(target:Tile) -> void:
	if !_can_use_ability(target): return
	
	print("Used fireball on tile: ", target)
	_use_resources()
	var tiles_in_aoe:Array[Tile] = GlobalSignals.current_level.tile_manager.get_tiles_in_aoe(target, ability_aoe)
	var fire_attack:Attack = _create_attack()
	
	#TODO animate spell
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	for tile:Tile in tiles_in_aoe:
		if tile.occupant:
			AttackHandler.use_attack_on_char(tile.occupant, fire_attack)

func _create_attack() -> Attack:
	var fire_attack:Attack = Attack.new()
	fire_attack.attacker = ability_owner
	fire_attack.damages[Stats.DmgType.FIRE] = 1
	
	return fire_attack
