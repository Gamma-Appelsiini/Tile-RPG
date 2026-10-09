extends PanelContainer
class_name InventoryPanel

@export var inv_square_container: GridContainer
@export var equipment_panel: EquipmentPanel
@export var currency_amount_label: Label
@export var skill_gem_amount_label: Label
@export var crafting_ore_amount_label: Label

const ITEM_TOOLTIP := preload("uid://cnufbt7pmxsc2")
const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const INVENTORY_SIZE:int = 50

var hovered_square:InventorySquare = null
var hovered_inv_item:InventoryItem = null:
	set(value):
		hovered_inv_item = value
		if !value: shared_tooltip.hide()
		_show_tooltip(hovered_inv_item)

var inventory_items:Array[InventoryItem] = []
var squares_dict:Dictionary[Vector2i, InventorySquare] = {}
var items_in_inventory:Dictionary[InventoryItem, InventorySquare] = {}
var items_equipped:Dictionary[InventoryItem, EquipmentSquare] = {}

var lifted_inv_item:InventoryItem = null
var old_square_before_lifting:InventorySquare = null
var old_equipment_square_before_lifting:EquipmentSquare = null
var lifting_item_square:InventorySquare = null
var lifted_item_squares_to_occupy:Array[InventorySquare] = []

var shared_tooltip:ItemTooltip = null

#Currencies
var player_currency:int = 0:
	set(value):
		player_currency = max(0, value)
		currency_amount_label.text = str(player_currency)
		
var player_skill_gems:int = 0:
	set(value):
		player_skill_gems = max(0, value)
		skill_gem_amount_label.text = str(player_skill_gems)

var player_crafting_ore:int = 0:
	set(value):
		player_crafting_ore = max(0, value)
		crafting_ore_amount_label.text = str(player_crafting_ore)

var player_skill_points:int = 10:
	set(value):
		player_skill_points = max(0, value)
		GlobalSignals.skill_gem_amount_changed.emit()

func _ready() -> void:
	set_process(false)
	shared_tooltip = ITEM_TOOLTIP.instantiate()
	add_child(shared_tooltip)
	_add_inv_squares()
	
	await get_tree().process_frame
	add_item_to_inv(ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.STAFF))
	add_item_to_inv(ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.SHIELD))
	add_item_to_inv(ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.SWORD))
	while add_item_to_inv(ItemGenerator.get_equipment()):
		pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"): _lift_up_item()
	elif event.is_action_released("Left Click"): _drop_item()

func _process(_delta: float) -> void:
	if !lifted_inv_item:
		print_debug("No item being lifted")
		return

	_set_lifting_item_square()

func _show_tooltip(inv_item:InventoryItem) -> void:
	if !inv_item: return
	
	shared_tooltip.generate_tooltip(inv_item.item)
	var offset:Vector2 = Vector2(inv_item.size.x + 15, 0)
	var screen_width: float = get_viewport_rect().size.x

	if inv_item.global_position.x > screen_width / 2.0:
		offset.x = -shared_tooltip.get_tt_size().x - 15
		shared_tooltip.right_diamond.show()
		shared_tooltip.left_diamond.hide()
	else:
		shared_tooltip.right_diamond.hide()
		shared_tooltip.left_diamond.show()
		
	offset.y = inv_item.size.y / 2 - shared_tooltip.get_tt_size().y / 2
	
	shared_tooltip.global_position = inv_item.global_position + offset
	shared_tooltip.show()

func _set_lifting_item_square() -> void:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	lifted_inv_item.global_position = mouse_pos + Vector2(-lifted_inv_item.size.x/2,-lifted_inv_item.size.y/2)
	
	var new_placement_square:InventorySquare = hovered_square
	if new_placement_square == lifting_item_square:
		if !new_placement_square: _clear_lifted_item_indicators()
		return
	
	lifting_item_square = new_placement_square
	_clear_lifted_item_indicators()
	if !new_placement_square:
		return
	
	lifted_item_squares_to_occupy = _get_squares_for_item_placement(new_placement_square, lifted_inv_item.item)
	for new_square:InventorySquare in lifted_item_squares_to_occupy:
		if new_square.occupied: new_square.cant_place_rect.show()
		else: new_square.placement_rect.show()

func _clear_lifted_item_indicators() -> void:
	for old_square:InventorySquare in lifted_item_squares_to_occupy:
		if old_square.occupied:
			old_square.cant_place_rect.hide()
		else:
			old_square.placement_rect.hide()

	lifted_item_squares_to_occupy.clear()
	lifting_item_square = null

#TODO
func _drop_item_on_equipment_slot(dropped_inv_item:InventoryItem) -> void:
	var switched_inv_item:InventoryItem = null
	#Not equipment
	if dropped_inv_item.item is not Equipment:
		_try_to_place_inventory_item_on_square(old_square_before_lifting, dropped_inv_item)
		lifted_inv_item = null
		old_square_before_lifting = null
		return
	
	var dropped_equipment:Equipment = dropped_inv_item.item as Equipment
	var main_hand_equipment:Equipment = null
	if equipment_panel.equipment_squares[Equipment.EquipmentSlot.MAIN_HAND].inventory_item_in_square:
		main_hand_equipment = equipment_panel.equipment_squares[Equipment.EquipmentSlot.MAIN_HAND].inventory_item_in_square.item as Equipment
	var off_hand_equipment:Equipment = null
	if equipment_panel.equipment_squares[Equipment.EquipmentSlot.OFF_HAND].inventory_item_in_square:
		off_hand_equipment = equipment_panel.equipment_squares[Equipment.EquipmentSlot.OFF_HAND].inventory_item_in_square.item as Equipment

	#Wrong slot
	if dropped_inv_item.item.equipment_slot != equipment_panel.hovered_equipment_square.equipment_slot:
		_try_to_place_inventory_item_on_square(old_square_before_lifting, dropped_inv_item)
		lifted_inv_item = null
		old_square_before_lifting = null
		return
	#is it wep
	if dropped_equipment is Weapon:
		if dropped_equipment.hand_type == Weapon.HandType.TWO_HANDED:
			#Equipping 2 handed while off hand taken and main hand free = switch off hand
			if !main_hand_equipment and off_hand_equipment:
				switched_inv_item = equipment_panel.equipment_squares[Equipment.EquipmentSlot.OFF_HAND].inventory_item_in_square
			#2 handed while both taken, don't equip
			elif off_hand_equipment and main_hand_equipment:
				if !old_square_before_lifting or !_try_to_place_inventory_item_on_square(old_square_before_lifting, dropped_inv_item):
					_place_in_first_free_spot(dropped_inv_item)
					lifted_inv_item = null
					old_square_before_lifting = null
					return
	#If equipping shield while having 2 handed
	elif dropped_equipment.equipment_slot == Equipment.EquipmentSlot.OFF_HAND:
		if main_hand_equipment:
			if main_hand_equipment is Weapon:
				if main_hand_equipment.hand_type == Weapon.HandType.TWO_HANDED:
					switched_inv_item = equipment_panel.equipment_squares[Equipment.EquipmentSlot.MAIN_HAND].inventory_item_in_square
	
	if equipment_panel.hovered_equipment_square.inventory_item_in_square or switched_inv_item:
		#Switch same slot item
		if !switched_inv_item: switched_inv_item = equipment_panel.hovered_equipment_square.inventory_item_in_square
		_lift_up_item(switched_inv_item)

	#TODO equip on equipment handler
	items_equipped[dropped_inv_item] = equipment_panel.hovered_equipment_square
	equipment_panel.hovered_equipment_square.inventory_item_in_square = dropped_inv_item
	dropped_inv_item.global_position = equipment_panel.hovered_equipment_square.global_position
	if equipment_panel.hovered_equipment_square.size.x > dropped_inv_item.size.x or equipment_panel.hovered_equipment_square.size.y > dropped_inv_item.size.y:
		dropped_inv_item.global_position += Vector2((equipment_panel.hovered_equipment_square.size.x - dropped_inv_item.size.x) / 2,
		(equipment_panel.hovered_equipment_square.size.y - dropped_inv_item.size.y) / 2)
	
	if !switched_inv_item:
		lifted_inv_item = null
		old_square_before_lifting = null

func _drop_item() -> void:
	if !lifted_inv_item: return

	set_process(false)
	_clear_lifted_item_indicators()
	lifted_inv_item.modulate.a = 1
	lifted_inv_item.z_index = 0
	
	#Can mouse over items again
	for inv_item:InventoryItem in items_in_inventory.keys():
		inv_item.mouse_filter = Control.MOUSE_FILTER_STOP

	var dropped_inv_item:InventoryItem = lifted_inv_item
	if equipment_panel.hovered_equipment_square:
		_drop_item_on_equipment_slot(dropped_inv_item)
		return
	
	var target_square:InventorySquare = hovered_square

	if target_square:
		if _try_to_place_inventory_item_on_square(target_square, dropped_inv_item):
			lifted_inv_item = null
			old_square_before_lifting = null
			return

		var items_in_squares:Array[InventoryItem] = []
		for square:InventorySquare in _get_squares_for_item_placement(target_square, dropped_inv_item.item):
			var item_in_square:InventoryItem = square.inv_item_in_square
			if item_in_square != null and !items_in_squares.has(item_in_square):
				items_in_squares.push_back(item_in_square)

		#Only 1 item under lifted item, lift item under
		if items_in_squares.size() == 1:
			var switched_inv_item:InventoryItem = items_in_squares[0]
			_remove_item_from_square(items_in_inventory[switched_inv_item])
			_try_to_place_inventory_item_on_square(target_square, dropped_inv_item)
			_lift_up_item(switched_inv_item)
			return

	# No target, out of bounds, or multiple items in the way: place back on original spot
	if !old_square_before_lifting or !_try_to_place_inventory_item_on_square(old_square_before_lifting, dropped_inv_item):
		_place_in_first_free_spot(dropped_inv_item)
	
	lifted_inv_item = null
	old_square_before_lifting = null

func _place_in_first_free_spot(inv_item:InventoryItem) -> bool:
	for square:InventorySquare in squares_dict.values():
		if _try_to_place_inventory_item_on_square(square, inv_item): return true
	return false

func _try_to_place_inventory_item_on_square(starting_square:InventorySquare, new_inventory_item:InventoryItem) -> bool:
	var squares_to_occupy:Array[InventorySquare] = _get_squares_for_item_placement(starting_square, new_inventory_item.item)
	if squares_to_occupy == []: return false
	for square in squares_to_occupy: if square.occupied: return false

	for square:InventorySquare in squares_to_occupy:
		square.occupied = true
		square.inv_item_in_square = new_inventory_item
	
	items_in_inventory[new_inventory_item] = starting_square
	starting_square.inv_item_in_square = new_inventory_item
	
	new_inventory_item.global_position = starting_square.global_position
	new_inventory_item.show()
	
	return true

func _lift_up_item(override_inv_item:InventoryItem = null) -> void:
	if lifted_inv_item and !override_inv_item: return
	if !hovered_inv_item and !override_inv_item: return

	lifted_inv_item = override_inv_item if override_inv_item else hovered_inv_item

	lifted_inv_item.modulate.a = 0.65
	lifted_inv_item.z_index = 2
	old_square_before_lifting = items_in_inventory[lifted_inv_item]

	# Swapped items were already removed from the grid in _drop_item()
	if items_equipped.keys().has(lifted_inv_item):
		items_equipped[lifted_inv_item].inventory_item_in_square = null
		items_equipped.erase(lifted_inv_item)
		#TODO unequip from equipment handler
	elif !override_inv_item:
		_remove_item_from_square(items_in_inventory[lifted_inv_item])

	for inv_item:InventoryItem in items_in_inventory.keys():
		inv_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		if i_item.item == null:
			free_inventory_item = i_item
			break
	
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
	
	var new_inventory_item:InventoryItem = _get_inventory_item(item)
	items_in_inventory[new_inventory_item] = starting_square
	
	for square:InventorySquare in squares_to_occupy:
		square.inv_item_in_square = new_inventory_item
		square.occupied = true
	
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
		square.inv_item_in_square = null
		square.occupied = false

func remove_item_from_inventory(item:Item) -> void:
	for inv_item:InventoryItem in items_in_inventory.keys():
		if inv_item.item != item: continue
		
		var starting_square:InventorySquare = items_in_inventory[inv_item]
		_remove_item_from_square(starting_square)
		inv_item.remove_item()
		items_in_inventory.erase(inv_item)
