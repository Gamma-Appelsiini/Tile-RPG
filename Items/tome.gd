extends Item
class_name Tome

var ability_path_taught_by_tome:String = ""

#Overrided
func _on_double_click() -> void:
	var new_ability:Ability = load(ability_path_taught_by_tome).instantiate()
	new_ability.ability_owner = GlobalSignals.player
	if GlobalSignals.ui_handler.abilities_container.add_new_ability(new_ability):
		GlobalSignals.ui_handler.inventory.remove_item_from_inv(self)
	
#Overrided
func save_to_data() -> Dictionary:
	return {}

#Overrided
func load_from_data(save_data:Dictionary) -> void:
	print(save_data)
