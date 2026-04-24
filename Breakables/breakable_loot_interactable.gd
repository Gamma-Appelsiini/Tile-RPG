extends Interactable
class_name BreakableLootInteractable

const GROUND_DROP := preload("uid://cuocgxmrrsjwt")

@export var breakable:Breakable = null

#Overrided
func interact() -> void:
	_create_loot()
	breakable.on_interaction(player)
	await breakable.broken
	interact_complete.emit()

func _create_loot() -> void:
	var number:int = randi_range(1,10)
	
	if number <= 3:
		#nothing
		pass
	elif number <= 8:
		#money
		_drop_money()
	else:
		#grea
		_drop_random_loot()

func _drop_money() -> void:
	await breakable.broken
	
	var ground_drop:GroundDrop = GROUND_DROP.instantiate()
	ground_drop.set_money()
	GlobalSignals.current_level.add_child(ground_drop)
	ground_drop.global_position = breakable.global_position
	ground_drop.shoot_rigidbody()

func _drop_random_loot() -> void:
	await breakable.broken

	var random_loot:Item = ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.RANDOM,player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL),2, Item.ItemRarity.RANDOM)
	var ground_drop:GroundDrop = GROUND_DROP.instantiate()
	ground_drop.set_item(random_loot)
	GlobalSignals.current_level.add_child(ground_drop)
	ground_drop.global_position = breakable.global_position
	ground_drop.shoot_rigidbody()
