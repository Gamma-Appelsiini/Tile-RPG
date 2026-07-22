extends Ability
class_name Fireball

const FIREBALL_PROJECTILE := preload("uid://cdqg505uijw8u")
const EXPLOSION_EFFECT := preload("uid://oa68ogevos7a")
const TILE_BURN := preload("uid://dmwkl2a0tadls")

func _shoot_fire_projectile(target:Tile) -> void:
	var y_offset:float = 0.35
	var new_projectile:Projectile = FIREBALL_PROJECTILE.instantiate()
	ability_owner.char_model_handler.main_hand_node.add_child(new_projectile)
	new_projectile.show()
	
	await ability_owner.get_tree().create_timer( ATTACK_DELAYS[CharacterModelHandler.CharAnimation.CAST_SPELL] ).timeout
	
	new_projectile.shoot_at_pos(target.global_position + Vector3(0,y_offset,0) )
	await new_projectile.hit_target

func use_ability_on_target_tile(target:Tile) -> void:
	if !_can_use_ability(target):
		ability_finished.emit()
		return

	_use_resources()
	var tiles_in_aoe:Array[Tile] = GlobalSignals.current_level.tile_manager.get_tiles_in_aoe(target, ability_aoe)
	var fire_attack:Attack = get_attack()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(CharacterModelHandler.CharAnimation.CAST_SPELL)

	await _shoot_fire_projectile(target)
	_spawn_explosion_effect(target)
	_set_tiles_on_fire(tiles_in_aoe)
	
	for tile:Tile in tiles_in_aoe:
		if tile.occupant:
			AttackHandler.use_attack_on_char(tile.occupant, fire_attack)
			_spawn_hit_effect(tile.occupant)
			
	ability_finished.emit()

func _set_tiles_on_fire(tiles_in_aoe:Array[Tile]) -> void:
	var fire_chance:int = 2 * ability_owner.stat_handler.get_stat_amount(Stats.MainStat.LUCK)
	fire_chance = 75
	
	for tile:Tile in tiles_in_aoe:
		if randi_range(1,100) < fire_chance:
			var new_tile_fire:TileBurn = TILE_BURN.instantiate()
			GlobalSignals.current_level.add_child(new_tile_fire)
			new_tile_fire.set_on_tile(tile)


func _spawn_explosion_effect(target:Tile) -> void:
	var new_explosion:Effect = EXPLOSION_EFFECT.instantiate()
	GlobalSignals.current_level.add_child(new_explosion)
	
	var aoe:int = get_aoe()
	new_explosion.scale = Vector3(aoe, aoe, aoe)
	
	new_explosion.global_position = target.global_position
	new_explosion.play_effect()

#Overrided
func get_attack(_is_min:bool = false, _is_max:bool = false) -> Attack:
	var fire_attack:Attack = Attack.new()
	fire_attack.attacker = ability_owner
	
	var dmg_from_level:int = ability_owner.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) * 2
	var dmg_from_mystic:int = int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MYSTIC) / 2.0 )
	fire_attack.damages[Stats.DmgType.FIRE] = 2 + dmg_from_level + dmg_from_mystic
	
	fire_attack.apply_damage_increases()
	fire_attack.calculate_crit()
	
	return fire_attack

#Overrided
func get_range() -> int:
	var range_increase:int = 0
	range_increase += int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.AGILITY) / 5.0 )
	if ability_tags.has(ABILITY_TAG.SPELL): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.SPELL_RANGE]
	if ability_tags.has(ABILITY_TAG.RANGED): range_increase += ability_owner.stat_handler.secondary_stats[Stats.SecondaryStat.BOW_RANGE]
	return ability_range + range_increase

#Overrided
func get_aoe() -> int:
	var aoe_increase:int = 0
	aoe_increase += int( ability_owner.stat_handler.get_stat_amount(Stats.MainStat.MIGHT) / 5.0 )
	
	return ability_aoe + aoe_increase
