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
	attack = _create_attack()
	
	ability_owner.rotate_towards_point(target.global_position)
	await ability_owner.rotation_complete
	
	ability_owner.char_model_handler.play_animation(self.use_animation)
	await ability_owner.get_tree().create_timer(self.hit_delay).timeout
	
	_spawn_rocks(target)
	await rocks_finished
	ability_finished.emit()
	
	
func _spawn_rocks(target:GameCharacter) -> void:
	var owner_tile:Tile = GlobalSignals.current_level.tile_manager.get_character_tile(ability_owner)
	var enemy_tile:Tile = GlobalSignals.current_level.tile_manager.get_character_tile(target)
	var path_to_target:Array[Tile] = GlobalSignals.current_level.tile_manager.get_shortest_path(owner_tile, enemy_tile)
	

	for tile:Tile in path_to_target:
		var new_rock:SunderRock = rock.duplicate()
		new_rock.global_position = tile.global_position
		
		add_child(new_rock)
		new_rock.spawn_rock()
		
		if GlobalSignals.combat_manager.is_in_same_team(ability_owner, tile.occupant): continue
		_spawn_hit_effect(tile.occupant)
		AttackHandler.use_attack_on_char(tile.occupant, attack)
		
		await get_tree().create_timer(0.15).timeout
		
	rocks_finished.emit()

func _create_attack() -> Attack:
	var new_attack:Attack = Attack.new()
	new_attack.attacker = ability_owner
	
	_get_weapon_dmg_to_attack(new_attack)
	new_attack.calculate_weapon_damage_increase()
	new_attack.calculate_crit()
	
	return new_attack
