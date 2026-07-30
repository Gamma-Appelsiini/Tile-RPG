extends Ability
class_name Sunder

signal rocks_finished

const SUNDER_ROCK := preload("uid://d3iy2enfmckc0")

var rock:SunderRock = SUNDER_ROCK.instantiate()
var attack:Attack = null

#Overrided
func use_ability_on_target_character(target:GameCharacter) -> void:
	if !_can_use_ability(target):
		ability_finished.emit()
		return
	
	_use_resources()
	attack = get_attack()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(self.use_animation)
	await ability_owner.get_tree().create_timer(self.hit_delay).timeout
	
	_spawn_rocks(target)
	await rocks_finished
	ability_finished.emit()

#Overrided
func _set_ability_weapon_range(_weapon:Weapon) -> void:
	pass

#Overrided
func get_range() -> int:
	var weapon:Weapon = ability_owner.equipment_handler.equipped_items[Equipment.EquipmentSlot.MAIN_HAND]
	if !weapon: return -1
	var range_increase:int = weapon.weapon_stats[Weapon.WeaponStat.RANGE]
	return ability_range + range_increase

func _spawn_rocks(target:GameCharacter) -> void:
	var owner_tile:Tile = GlobalSignals.current_level.tile_manager.get_character_tile(ability_owner)
	var enemy_tile:Tile = GlobalSignals.current_level.tile_manager.get_character_tile(target)
	var path_to_target:Array[Tile] = GlobalSignals.current_level.tile_manager.get_shortest_path(owner_tile, enemy_tile, false, true)
	path_to_target = path_to_target.slice(1)

	for tile:Tile in path_to_target:
		var new_rock:SunderRock = rock.duplicate()
		
		ability_owner.get_parent().add_child(new_rock)
		if tile == path_to_target.back(): new_rock.scale = Vector3(1.3,1.3,1.3)
		new_rock.global_position = tile.global_position
		new_rock.spawn_rock()
		await ability_owner.get_tree().create_timer(0.25).timeout
		
		if !tile.occupant: continue
		if GlobalSignals.combat_manager.is_in_same_team(ability_owner, tile.occupant): continue
		_spawn_hit_effect(tile.occupant)
		AttackHandler.use_attack_on_char(tile.occupant, attack)

	rocks_finished.emit()

#Overrided
func get_attack(is_min:bool = false, is_max:bool = false) -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack, is_min, is_max)
	new_attack.calculate_weapon_damage_increase()
	new_attack.apply_damage_increases()
	new_attack.calculate_crit()
	
	return new_attack
