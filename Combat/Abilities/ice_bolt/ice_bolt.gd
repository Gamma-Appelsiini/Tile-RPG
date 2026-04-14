extends Ability
class_name IceBolt

const ICE_BLOCK_EXPLOSION_EFFECT := preload("uid://du0vc10vsrk5k")
const FREEZE_STATUS := preload("uid://6enlcywwmbt7")
const ICE_PROJECTILE := preload("uid://8sp4d6thsghn")

var blocks:Effect = null

func _shoot_ice_projectile(target:GameCharacter) -> void:
	var y_offset:float = 1.5
	var new_projectile:Projectile = ICE_PROJECTILE.instantiate()
	ability_owner.char_model_handler.main_hand_node.add_child(new_projectile)
	new_projectile.show()
	
	await ability_owner.get_tree().create_timer( ATTACK_DELAYS[CharacterModelHandler.CharAnimation.CAST_SPELL] ).timeout
	
	new_projectile.shoot_at_pos(target.global_position + Vector3(0,y_offset,0) )
	await new_projectile.hit_target
	
	_spawn_explosion(target.global_position + Vector3(0,y_offset,0))

#Overrided
func get_dmg() -> Dictionary[Stats.DmgType,int]:
	var attack:Attack = _create_attack()
	return attack.damages

func _create_attack() -> Attack:
	var ice_attack:Attack = Attack.new()
	ice_attack.attacker = ability_owner
	
	var dmg_from_level:int = int(ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) * 1.5)
	var dmg_from_mystic:int = int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MYSTIC) / 1.5 )
	var max_dmg:int = 2 + dmg_from_level + dmg_from_mystic
	var min_dmg:int = 1
	ice_attack.damages[Stats.DmgType.FROST] = randi_range(min_dmg, max_dmg)
	
	return ice_attack

func _spawn_explosion(pos:Vector3) -> void:
	blocks = ICE_BLOCK_EXPLOSION_EFFECT.instantiate()
	
	GlobalSignals.current_level.add_child(blocks)
	blocks.global_position = pos

func use_ability_on_target_character(target:GameCharacter) -> void:
	if !_can_use_ability(target):
		ability_finished.emit()
		return
	
	_use_resources()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.CAST_SPELL)
	await _shoot_ice_projectile(target)
	
	_freeze_target(target)
	_spawn_hit_effect(target)
	
	var ice_attack:Attack = _create_attack()
	AttackHandler.use_attack_on_char(target, ice_attack)
	
	await ability_owner.char_model_handler.animation_player.animation_finished
	ability_finished.emit()

func _freeze_target(target:GameCharacter) -> void:
	await ability_owner.get_tree().create_timer(0.2).timeout
	if target.stat_handler.get_stat_amount(Stats.ResourceStat.CURRENT_HP) <= 0: return
	
	var freeze_chance:int = 5 + ability_owner.stat_handler.get_stat_amount(Stats.MainStat.LUCK)
	if randi_range(0, 100) > freeze_chance: return
	
	var new_freeze:Status = FREEZE_STATUS.instantiate()
	target.status_handler.add_status(new_freeze)
