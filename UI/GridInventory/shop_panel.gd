extends MarginContainer
class_name ShopPanel

@export var inventory_panel:InventoryPanel = null
@export var inv_square_container: GridContainer

const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const SQUARE_AMOUNT:int = 80

var shop_items:Array[InventoryItem] = []

func _ready() -> void:
	inventory_panel.shop_panel = self
	_add_squares()
	
func _add_squares() -> void:
	for number:int in SQUARE_AMOUNT:
		var new_inv_square:InventorySquare = INVENTORY_SQUARE.instantiate()
		inv_square_container.add_child(new_inv_square)
		
		new_inv_square.pos_x = number % 10
		new_inv_square.pos_y = int(number / 10)
		inventory_panel.shop_squares_dict[Vector2i(new_inv_square.pos_x, new_inv_square.pos_y)] = new_inv_square
		
		new_inv_square.mouse_entered.connect(func(): inventory_panel.hovered_square = new_inv_square)
		new_inv_square.mouse_exited.connect(func(): if inventory_panel.hovered_square == new_inv_square: inventory_panel.hovered_square = null)

func open_shop(shop_resource:ShopResource) -> void:
	pass
