extends Ability
class_name SkyHammer

const STUNNED_STATUS := preload("uid://nrt6scp03udd")
const HAMMER_SLAM_EFFECT := preload("uid://ducmby7ykroxt")
const SLAM_TIME:float = 1.0

func use_ability_on_target_tile(target:Tile) -> void:
	if !_can_use_ability(target):
		ability_finished.emit()
		return

	_use_resources()

	var tiles_in_aoe:Array[Tile] = get_tiles_in_aoe(target)
	var hammer_attack:Attack = get_attack()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.ATTACK_2H)

	var hammer_effect:Effect = HAMMER_SLAM_EFFECT.instantiate()
	ability_owner.add_child(hammer_effect)
	hammer_effect.look_at(target.global_position)
	hammer_effect.global_position = target.global_position
	
	await ability_owner.get_tree().create_timer(SLAM_TIME).timeout
	
	for tile:Tile in tiles_in_aoe:
		if tile.occupant:
			AttackHandler.use_attack_on_char(tile.occupant, hammer_attack)
			_spawn_hit_effect(tile.occupant)
			_stun_target(tile.occupant)
			
	ability_finished.emit()

#Overrided
func get_tiles_in_aoe(target:Tile) -> Array[Tile]:
	if target == null: return []
	
	var tiles_in_aoe:Array[Tile] =  target.diagonal_tiles + target.neighbor_tiles
	tiles_in_aoe.push_back(target)
	return tiles_in_aoe


#Overrided
func get_attack(_is_min:bool = false, _is_max:bool = false) -> Attack:
	var hammer_attack:Attack = Attack.new()
	hammer_attack.attacker = ability_owner
	
	var dmg_from_level:int = ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) * 2
	var dmg_from_might:int = int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MIGHT) / 2.0 )
	hammer_attack.damages[Stats.DmgType.PHYSICAL] = 2 + dmg_from_level + dmg_from_might
	
	hammer_attack.apply_damage_increases()
	hammer_attack.calculate_crit()
	
	return hammer_attack


func _stun_target(target:GameCharacter) -> void:
	await ability_owner.get_tree().create_timer(0.25).timeout
	if target.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP) <= 0: return
	
	var stun_chance:int = 5 + ability_owner.stat_handler.get_stat_amount(Stats.MainStat.LUCK)
	if randi_range(0, 100) > stun_chance: return
	
	var new_stun:Status = STUNNED_STATUS.instantiate()
	target.status_handler.add_status(new_stun)
