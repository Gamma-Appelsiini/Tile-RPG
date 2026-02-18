extends Ability
class_name SkyHammer

const STUNNED_STATUS := preload("uid://nrt6scp03udd")

func use_ability_on_target_tile(target:Tile) -> void:
	if !_can_use_ability(target): return

	_use_resources()
	#Square aoe
	var tiles_in_aoe:Array[Tile] = target.diagonal_tiles + target.neighbor_tiles + [target]
	var hammer_attack:Attack = _create_attack()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	#ability_owner.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.CAST_SPELL)

	#await _shoot_fire_projectile(target)
	#_spawn_explosion_effect(target)
	
	for tile:Tile in tiles_in_aoe:
		if tile.occupant:
			AttackHandler.use_attack_on_char(tile.occupant, hammer_attack)
			_spawn_hit_effect(tile.occupant)
			if tile.occupant.char_model_handler.animation_player.is_playing():
				await tile.occupant.char_model_handler.animation_player.animation_finished
			_stun_target(tile.occupant)

func _create_attack() -> Attack:
	var hammer_attack:Attack = Attack.new()
	hammer_attack.attacker = ability_owner
	
	var dmg_from_level:int = ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) * 2
	var dmg_from_mystic:int = int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MYSTIC) / 2.0 )
	hammer_attack.damages[Stats.DmgType.PHYSICAL] = 2 + dmg_from_level + dmg_from_mystic
	
	return hammer_attack

func _stun_target(target:GameCharacter) -> void:
	await ability_owner.get_tree().create_timer(0.2).timeout
	if target.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP) <= 0: return
	
	var stun_chance:int = 5 + ability_owner.stat_handler.get_stat_amount(Stats.MainStat.LUCK)
	if randi_range(0, 100) > stun_chance: return
	
	var new_stun:Status = STUNNED_STATUS.instantiate()
	target.status_handler.add_status(new_stun)
