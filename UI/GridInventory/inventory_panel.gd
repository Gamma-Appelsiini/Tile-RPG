extends PanelContainer
class_name InventoryPanel

@export var inv_square_container: GridContainer

const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const INVENTORY_SIZE:int = 50

var hovered_square:InventorySquare = null
var hovered_inv_item:InventoryItem = null

var inventory_items:Array[InventoryItem] = []
var squares_dict:Dictionary[Vector2i, InventorySquare] = {}
var items_in_inventory:Dictionary[InventoryItem, InventorySquare] = {}

var lifted_inv_item:InventoryItem = null
var old_square_before_lifting:InventorySquare = null

func _ready() -> void:
	set_process(false)
	_add_inv_squares()
	
	await get_tree().process_frame
	var rand_eq:Equipment = ItemGenerator.get_equipment()
	add_item_to_inv(rand_eq)
	rand_eq = ItemGenerator.get_equipment()
	add_item_to_inv(rand_eq)
	rand_eq = ItemGenerator.get_equipment()
	add_item_to_inv(rand_eq)
	rand_eq = ItemGenerator.get_equipment()
	add_item_to_inv(rand_eq)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_pick_up_item()
	elif event.is_action_released("Left Click"):
		_drop_item()

func _process(_delta: float) -> void:
	if !lifted_inv_item:
		print_debug("No hover item")
		return
	lifted_inv_item.global_position = get_viewport().get_mouse_position() + Vector2(-lifted_inv_item.size.x/2,-lifted_inv_item.size.y/2)

func _drop_item() -> void:
	if !hovered_square:
		return
	
	set_process(false)
	for inv_item:InventoryItem in items_in_inventory.keys(): inv_item.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if !_try_to_place_inventory_item_on_square(hovered_square, lifted_inv_item):
		_try_to_place_inventory_item_on_square(old_square_before_lifting, lifted_inv_item)
		
	lifted_inv_item = null
	old_square_before_lifting = null

func _try_to_place_inventory_item_on_square(starting_square:InventorySquare, new_inventory_item:InventoryItem) -> bool:
	var squares_to_occupy:Array[InventorySquare] = _get_squares_for_item_placement(starting_square, new_inventory_item.item)
	if squares_to_occupy == []: return false
	for square in squares_to_occupy: if square.occupied: return false

	for square:InventorySquare in squares_to_occupy:
		square.occupied = true
	
	items_in_inventory[new_inventory_item] = starting_square
	starting_square.inv_item_in_square = new_inventory_item
	
	new_inventory_item.global_position = starting_square.global_position
	new_inventory_item.show()
	
	return true

func _pick_up_item() -> void:
	if !hovered_inv_item: return
	
	lifted_inv_item = hovered_inv_item
	lifted_inv_item.modulate.a = 0.5
	lifted_inv_item.z_index = 2
	old_square_before_lifting = items_in_inventory[lifted_inv_item]
	_remove_item_from_square(items_in_inventory[lifted_inv_item])
	for inv_item:InventoryItem in items_in_inventory.keys(): inv_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _is_mouse_in_drop_position() -> bool:
	#if crafting_window_open: return false
	const FROM_LEFT:float = 0.65
	var viewport:Viewport = get_viewport()
	var mouse_x:float = viewport.get_mouse_position().x
	var screen_width:float = viewport.get_visible_rect().size.x

	return mouse_x <= (screen_width * FROM_LEFT)

func _add_new_inventory_item() -> void:
	var new_inventory_item:InventoryItem = INVENTORY_ITEM.instantiate()
	add_child(new_inventory_item)
	new_inventory_item.top_level = true
	new_inventory_item.hide()
	inventory_items.push_back(new_inventory_item)
	
	new_inventory_item.mouse_entered.connect(func(): hovered_inv_item = new_inventory_item)
	new_inventory_item.mouse_exited.connect(func(): if hovered_inv_item == new_inventory_item: hovered_inv_item = null)
	
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
	var added_to_inv:bool = false
	
	for square:InventorySquare in squares_dict.values():
		added_to_inv = _try_to_place_item_on_square(square, new_item)
		if added_to_inv: return true
	
	return false

func _try_to_place_item_on_square(starting_square:InventorySquare, item:Item) -> bool:
	var squares_to_occupy:Array[InventorySquare] = _get_squares_for_item_placement(starting_square, item)
	if squares_to_occupy == []: return false
	for square in squares_to_occupy: if square.occupied: return false

	for square:InventorySquare in squares_to_occupy:
		square.occupied = true
	
	var new_inventory_item:InventoryItem = _get_inventory_item(item)
	items_in_inventory[new_inventory_item] = starting_square
	starting_square.inv_item_in_square = new_inventory_item
	
	new_inventory_item.global_position = starting_square.global_position
	new_inventory_item.show()
	
	return true

func _get_squares_for_item_placement(starting_square:InventorySquare, item:Item) -> Array[InventorySquare]:
	var start_y:int = starting_square.pos_y
	var start_x:int = starting_square.pos_x
	var squares_to_occupy:Array[InventorySquare] = []
	var current_square:InventorySquare = null
	
	for pos_y:int in item.inventory_height:
		for pos_x:int in item.inventory_width:
			if !squares_dict.has(Vector2i(start_x + pos_x, start_y + pos_y)): return []
			current_square = squares_dict[Vector2i(start_x + pos_x, start_y + pos_y)]
			squares_to_occupy.push_back(current_square)
	
	return squares_to_occupy

func _remove_item_from_square(starting_square:InventorySquare) -> void:
	var inv_item:InventoryItem = starting_square.inv_item_in_square
	var squares_occupied:Array[InventorySquare] = _get_squares_for_item_placement(starting_square, inv_item.item)
	
	for square:InventorySquare in squares_occupied:
		square.occupied = false

func remove_item_from_inventory(item:Item) -> void:
	for inv_item:InventoryItem in items_in_inventory.keys():
		if inv_item.item != item: continue
		
		var starting_square:InventorySquare = items_in_inventory[inv_item]
		_remove_item_from_square(starting_square)
		inv_item.remove_item()
