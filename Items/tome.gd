extends Item
class_name Tome

var ability_path_taught_by_tome:String = ""
var ability:Ability = null

func _init() -> void:
	item_model_path = "res://Tile-RPG/Items/ItemScenes/tome_model.tscn"
	inventory_image = load("res://Tile-RPG/Images/Items/tome.png")

func set_ability_path(path:String) -> void:
	ability_path_taught_by_tome = path
	ability = load(path).instantiate()
	
	item_name = ability.ability_name
	item_value = ability.ability_value
	item_rarity = ItemRarity.RARE

#Overrided
func _on_double_click() -> void:
	ability.ability_owner = GlobalSignals.player
	if GlobalSignals.ui_handler.abilities_container.add_new_ability(ability):
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
	set_ability_path(save_data["ability_path_taught_by_tome"])
