extends Control
class_name Inventory

@onready var inv_slot_grid: GridContainer = %InvSlotGrid

const INV_SIZE:int = 20
const INV_SLOT_PATH:String = "res://Tile-RPG/UI/Inventory/inventory_slot.tscn"

var items:Array[Item] = []
var slots:Array[InventorySlot] = []
var hovered_slot:InventorySlot = null
var selected_slot:InventorySlot = null
var old_slot_pos:Vector2 = Vector2.ZERO
var img_offset:int = 0

func _ready() -> void:
	items.resize(INV_SIZE)
	_add_inv_slots()
	var generator = ItemGenerator.new()
	add_item_to_inv(generator.get_random_equipment())

func _process(_delta: float) -> void:
	if selected_slot != null:
		selected_slot.item_image.global_position = get_viewport().get_mouse_position() + Vector2(-img_offset,-img_offset)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if hovered_slot == null: return
		_slot_clicked()
	elif event.is_action_released("Left Click"):
		_slot_released()

func add_item_to_inv(new_item:Item) -> bool:
	for i:int in INV_SIZE:
		if slots[i].item_in_slot == null:
			slots[i].set_item(new_item)
			return true
	
	return false

func _slot_clicked() -> void:
	if hovered_slot.item_in_slot == null: return
	
	old_slot_pos = hovered_slot.item_image.global_position
	selected_slot = hovered_slot
	img_offset = int(selected_slot.item_image.get_size().x / 2)
	
	#Enables mouse entered/exited signals to be fired when dragging item
	selected_slot.item_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _slot_released() -> void:
	if selected_slot == null: return
	
	#Hovering over nothing or own slot
	if hovered_slot == null or hovered_slot == selected_slot:
		selected_slot.item_image.global_position = old_slot_pos
		selected_slot = null
		return
	
	selected_slot.item_image.global_position = old_slot_pos
	hovered_slot.set_item(selected_slot.item_in_slot,selected_slot)
	selected_slot = null

func _add_inv_slots() -> void:
	for i:int in INV_SIZE:
		var new_slot:InventorySlot = load(INV_SLOT_PATH).instantiate()
		new_slot.array_pos = i
		inv_slot_grid.add_child(new_slot)
		slots.push_back(new_slot)
		
		new_slot.mouse_exited.connect(_clear_hover.bind(new_slot))
		new_slot.mouse_entered.connect(_slot_hovered.bind(new_slot))

func _slot_hovered(slot:InventorySlot) -> void:
	hovered_slot = slot
	slot.hover_slot()
	
func _clear_hover(slot:InventorySlot) -> void:
	if hovered_slot == slot: hovered_slot = null
	slot.unhover_slot()
