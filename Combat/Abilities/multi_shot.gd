extends Ability
class_name MultiShot

const BASIC_ATTACK := preload("uid://bs08mf1jnw3vi")

var basic_attack:BasicAttack = BASIC_ATTACK.instantiate()

func use_ability() -> void:
	if !_can_use_ability(null):
		ability_finished.emit()
		return

	var tiles_in_aoe:Array[Tile] = GlobalSignals.current_level.tile_manager.get_tiles_in_aoe(GlobalSignals.current_level.tile_manager.char_tiles[ability_owner], get_aoe())
	if tiles_in_aoe.is_empty():
		ability_finished.emit()
		return

	_use_resources()
	basic_attack.ability_owner = ability_owner

	for tile:Tile in tiles_in_aoe:
		if !tile.occupant or tile.occupant == ability_owner: continue
		if GlobalSignals.combat_manager.is_in_same_team(ability_owner, tile.occupant): continue
			
		basic_attack.use_ability_on_target_character(tile.occupant, false)
		await basic_attack.ability_finished

	ability_finished.emit()

#Overrided
func get_aoe() -> int:
	return ability_aoe + int(ability_owner.stat_handler.get_stat_amount(Stats.MainStat.AGILITY) / 15.0)
