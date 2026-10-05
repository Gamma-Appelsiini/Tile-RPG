extends PanelContainer
class_name InventoryItem

@export var item_image_rect: TextureRect
@export var hover_image_rect: NinePatchRect

const SQUARE_SIZE:int = 50

var item:Item = null

func _ready() -> void:
	mouse_entered.connect(func(): hover_image_rect.show())
	mouse_exited.connect(func(): hover_image_rect.hide())

func set_item(new_item:Item) -> void:
	item = new_item
	item_image_rect.texture = item.inventory_image
	custom_minimum_size = Vector2(SQUARE_SIZE * new_item.inventory_width, SQUARE_SIZE * new_item.inventory_height)
	custom_maximum_size = Vector2(SQUARE_SIZE * new_item.inventory_width, SQUARE_SIZE * new_item.inventory_height)

func remove_item() -> void:
	item = null
	item_image_rect.texture = null
	hover_image_rect.hide()
	hide()
