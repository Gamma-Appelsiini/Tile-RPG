extends Resource
class_name Item

signal remake_tt

enum ItemRarity {
	POOR,
	COMMON,
	RARE,
	EPIC,
	LEGENDARY,
	FABLED,
	GOD_ROLL,
	RANDOM
}

@export var item_name:String = "Default Name"
@export var inventory_image:Texture2D = load("res://Tile-RPG/Images/Items/Sword.png")
@export var item_value:int = 1
@export var item_rarity:ItemRarity = ItemRarity.POOR

func _init() -> void:
	resource_local_to_scene = true
	
#Override this
func save_to_data() -> Dictionary:
	return {}

#Override this
func load_from_data(save_data:Dictionary) -> void:
	print(save_data)
