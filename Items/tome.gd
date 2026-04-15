extends Item
class_name Tome

var ability_path_taught_by_tome:String = ""

func _init() -> void:
	item_model_path = "res://Tile-RPG/Items/ItemScenes/tome_model.tscn"
	inventory_image = load("res://Tile-RPG/Images/Items/tome.png")

#Overrided
func _on_double_click() -> void:
	var new_ability:Ability = load(ability_path_taught_by_tome).instantiate()
	new_ability.ability_owner = GlobalSignals.player
	if GlobalSignals.ui_handler.abilities_container.add_new_ability(new_ability):
		GlobalSignals.ui_handler.inventory.remove_item_from_inv(self)
	
#Overrided
func save_to_data() -> Dictionary:
	return {
		"item_type": "res://Tile-RPG/Items/tome.gd",
		"ability_path_taught_by_tome": ability_path_taught_by_tome,
		"item_rarity": item_rarity,
		"item_value": item_value,
		"item_name": item_name,
	}

#Overrided
func load_from_data(save_data:Dictionary) -> void:
	self.item_level = save_data["item_level"]
	self.item_rarity = save_data["item_rarity"]
	self.item_value = save_data["item_value"]
	self.item_name = save_data["item_name"]
	self.ability_path_taught_by_tome = save_data["ability_path_taught_by_tome"]
