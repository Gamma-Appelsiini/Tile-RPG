extends PanelContainer
class_name InventoryItem

@export var item_image_rect: TextureRect

const SQUARE_SIZE:int = 50

var item:Item = null

func _ready() -> void:
	pass

func set_item(new_item:Item) -> void:
	item = new_item
	item_image_rect.texture = item.inventory_image
	custom_minimum_size = Vector2(SQUARE_SIZE * new_item.inventory_width, SQUARE_SIZE * new_item.inventory_height)
	custom_maximum_size = Vector2(SQUARE_SIZE * new_item.inventory_width, SQUARE_SIZE * new_item.inventory_height)
