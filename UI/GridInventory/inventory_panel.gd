extends PanelContainer
class_name InventoryPanel

@export var inv_square_container: GridContainer

const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const INVENTORY_SIZE:int = 50

var hovered_square:InventorySquare = null
var inventory_items:Array[InventoryItem] = []
var squares_dict:Dictionary[Vector2i, InventorySquare] = {}
var items_in_inventory:Dictionary[InventorySquare, InventoryItem] = {}

func _ready() -> void:
	_add_inv_squares()

func _add_new_inventory_item() -> void:
	var new_inventory_item:InventoryItem = INVENTORY_ITEM.instantiate()
	add_child(new_inventory_item)
	new_inventory_item.top_level = true
	new_inventory_item.hide()
	inventory_items.push_back(new_inventory_item)
	
func _add_inv_squares() -> void:
	for number:int in INVENTORY_SIZE:
		var new_inv_square:InventorySquare = INVENTORY_SQUARE.instantiate()
		inv_square_container.add_child(new_inv_square)
		
		new_inv_square.pos_x = number % 10
		new_inv_square.pos_y = int(number / 10)
		squares_dict[Vector2i(new_inv_square.pos_x, new_inv_square.pos_y)] = new_inv_square
		
		new_inv_square.mouse_entered.connect(func(): hovered_square = new_inv_square)
		new_inv_square.mouse_exited.connect(func(): if hovered_square == new_inv_square: hovered_square = null)
		
		_add_new_inventory_item()
		
func _get_inventory_item(new_item:Item) -> InventoryItem:
	var free_inventory_item:InventoryItem = null
	for i_item:InventoryItem in inventory_items:
		if i_item.item == null: free_inventory_item = i_item
	
	free_inventory_item.set_item(new_item)
	
	return free_inventory_item

func add_item_to_inv(new_item:Item) -> bool:
	var fitting_square:InventorySquare = _get_fitting_square(new_item)
	if !fitting_square:return false
	
	var new_inventory_item:InventoryItem = _get_inventory_item(new_item)
	_set_inventory_item_on_square(fitting_square, new_inventory_item)
	
	return true

func _get_fitting_square(new_item:Item) -> InventorySquare:
	var fitting_square:InventorySquare = null
	#TODO
	
	return fitting_square

func _set_inventory_item_on_square(square:InventorySquare, inventory_item:InventoryItem) -> void:
	items_in_inventory[square] = inventory_item
	inventory_item.global_position = square.global_position
	inventory_item.show()
	#TODO
