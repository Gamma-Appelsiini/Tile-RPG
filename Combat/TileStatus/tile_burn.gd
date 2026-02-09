extends TileStatus
class_name TileBurn

var dmg:int = 1

func set_dmg(amount:int) -> void:
	dmg = amount

func _create_attack() -> Attack:
	var burn_attack:Attack = Attack.new()
	
	burn_attack.damages[Stats.DmgType.FIRE] = dmg
	burn_attack.main_damage_type = Stats.DmgType.FIRE
	burn_attack.set_tags( [ Ability.ABILITY_TAG.CANT_CRIT, Ability.ABILITY_TAG.NO_RETALIATION, Ability.ABILITY_TAG.DOT ] )

	return burn_attack

#Overrided
func _on_occupant_turn_start() -> void:
	var burn_attack:Attack = _create_attack()
	AttackHandler.use_attack_on_char(affected_tile.occupant, burn_attack)

#Overrided
func _on_tile_entered(_entering_character:GameCharacter) -> void:
	_entering_character.start_turn.connect(_on_occupant_turn_start)
	_entering_character.end_turn.connect(_on_occupant_turn_end)
	
	var burn_attack:Attack = _create_attack()
	AttackHandler.use_attack_on_char(_entering_character, burn_attack)
