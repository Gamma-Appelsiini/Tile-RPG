extends Control
class_name Inventory

@onready var inv_slot_grid: GridContainer = %InvSlotGrid
@onready var equipment_grid: GridContainer = %EquipmentGrid

const INV_SIZE:int = 15
const INV_SLOT_PATH:String = "res://Tile-RPG/UI/Inventory/inventory_slot.tscn"
const ITEM_TT_PATH:String = "res://Tile-RPG/UI/Inventory/item_tooltip.tscn"

var player:Player = null
var items:Array[Item] = []
var slots:Array[InventorySlot] = []
var equipment_slots:Dictionary[Equipment.EquipmentSlot,InventorySlot] = {}  
var tooltips:Dictionary[Item,ItemTooltip] = {}

var hovered_slot:InventorySlot = null
var selected_slot:InventorySlot = null
var old_slot_pos:Vector2 = Vector2.ZERO
var img_offset:int = 0

func _ready() -> void:
	items.resize(INV_SIZE)
	_add_inv_slots()
	_add_equipment_slots()

func _save_equipment(save_data:Dictionary) -> void:
	var equ_data:Dictionary = {}
	
	for slot:Equipment.EquipmentSlot in equipment_slots.keys():
		var equ_to_save:Equipment = equipment_slots[slot].item_in_slot
		if equ_to_save != null:
			equ_data[slot] = equ_to_save.save_to_data()
			
	save_data["equipment"] = equ_data

func _load_equ_from_data(save_data:Dictionary) -> void:
	if !save_data.has("equipment"): return
	
	for slot:Equipment.EquipmentSlot in save_data["equipment"].keys():
		var script: Script = load(save_data["equipment"][slot]["equipment_type"])
		var loaded_equ:Equipment = script.new()
		loaded_equ.load_from_data(save_data["equipment"][slot])
		_create_item_tt(loaded_equ)

		#Don't equip gear again, stats are saved with gear equipped
		player.equipment_handler.equipped_items[slot] = loaded_equ
		var skip_equipping:bool = true
		equipment_slots[slot].set_item(loaded_equ,null,skip_equipping)

func save_inv_to_data(save_data:Dictionary) -> void:
	var inv_data:Dictionary = {}
	
	for islot:InventorySlot in slots:
		if islot.array_pos != -1 and islot.item_in_slot != null:
			inv_data[islot.array_pos] = islot.item_in_slot.save_to_data()
			
	save_data["inventory"] = inv_data
	_save_equipment(save_data)

func load_inv_from_data(save_data:Dictionary) -> void:
	if !save_data.has("inventory"):return

	for key:int in save_data["inventory"].keys():
		var script: Script = load(save_data["inventory"][key]["equipment_type"])
		var loaded_equ:Equipment = script.new()

		loaded_equ.load_from_data(save_data["inventory"][key])
		slots[key].set_item(loaded_equ)
		_create_item_tt(loaded_equ)
	
	_load_equ_from_data(save_data)

func _process(_delta: float) -> void:
	if selected_slot != null:
		selected_slot.item_image.global_position = get_viewport().get_mouse_position() + Vector2(-img_offset,-img_offset)

func _input(event: InputEvent) -> void:
	if !visible: return
	if event.is_action_pressed("Left Click"):
		if hovered_slot == null: return
		_item_clicked()
	elif event.is_action_released("Left Click"):
		_item_released()
	elif event.is_action_released("Bag"):
		_reset_selecting()
	elif event.is_action_released("test2"):
		var generator = ItemGenerator.new()
		add_item_to_inv(generator.get_random_rarity_equipment())
		add_item_to_inv(generator.get_random_rarity_equipment())
		add_item_to_inv(generator.get_random_rarity_equipment())
		add_item_to_inv(generator.get_random_rarity_equipment())
		add_item_to_inv(generator.get_random_equipment(5,0,Item.ItemRarity.EPIC))
		add_item_to_inv(generator.get_random_equipment(5,0,Item.ItemRarity.RARE))

func _add_equipment_slots() -> void:
	var equ_slots:Array[Equipment.EquipmentSlot] =[
		Equipment.EquipmentSlot.NECK, Equipment.EquipmentSlot.HEAD,Equipment.EquipmentSlot.FINGER,
		Equipment.EquipmentSlot.HANDS, Equipment.EquipmentSlot.CHEST, Equipment.EquipmentSlot.FEET,
		Equipment.EquipmentSlot.MAIN_HAND, Equipment.EquipmentSlot.WAIST, Equipment.EquipmentSlot.OFF_HAND]
	
	for slot:Equipment.EquipmentSlot in equ_slots:
		var new_inv_slot:InventorySlot = load(INV_SLOT_PATH).instantiate()
		new_inv_slot.equipment_slot = slot
		equipment_grid.add_child(new_inv_slot)
		slots.push_back(new_inv_slot)
		equipment_slots[slot] = new_inv_slot
		new_inv_slot.custom_minimum_size = Vector2(140,140)
		
		new_inv_slot.equip_item.connect(player.equipment_handler.equip_item)
		new_inv_slot.unequip_item.connect(player.equipment_handler.unequip_item)
		new_inv_slot.mouse_exited.connect(_clear_hover.bind(new_inv_slot))
		new_inv_slot.mouse_entered.connect(_slot_hovered.bind(new_inv_slot))

func add_item_to_inv(new_item:Item) -> bool:
	for i:int in INV_SIZE:
		if slots[i].item_in_slot == null and !slots[i].equipment_slot:
			slots[i].set_item(new_item)
			_create_item_tt(new_item)
			return true
	
	return false
	
func remove_item_from_inv(remove_item:Item, destroy_item:bool = false) -> void:
	for i:int in INV_SIZE:
		if slots[i].item_in_slot == remove_item:
			tooltips[remove_item].queue_free()
			tooltips.erase(remove_item)
			slots[i].remove_item()
	if destroy_item: remove_item.queue_free()

func _create_item_tt(new_item:Item) -> void:
	var new_tooltip:ItemTooltip = load(ITEM_TT_PATH).instantiate()
	new_tooltip.visible = false
	add_child(new_tooltip)
	new_tooltip.generate_tooltip(new_item)
	
	tooltips[new_item] = new_tooltip

func _item_clicked() -> void:
	if hovered_slot.item_in_slot == null: return
	
	_hide_tt(hovered_slot)
	old_slot_pos = hovered_slot.item_image.global_position
	selected_slot = hovered_slot
	img_offset = int(selected_slot.item_image.get_size().x / 2)
	
	#Enables mouse entered/exited signals to be fired when dragging item
	selected_slot.item_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _reset_selecting() -> void:
	if selected_slot == null: return
	selected_slot.item_image.global_position = old_slot_pos
	selected_slot = null

func _item_released() -> void:
	if selected_slot == null: return
	
	#Hovering over nothing or own slot
	if hovered_slot == null or hovered_slot == selected_slot or !_possible_to_equip():
		_reset_selecting()
		return
	
	selected_slot.item_image.global_position = old_slot_pos
	hovered_slot.set_item(selected_slot.item_in_slot,selected_slot)
	selected_slot = null

#Equipping a two handed weapon requires unequipping off and mainhand
func _possible_to_equip() -> bool:
	if !hovered_slot.equipment_slot: return true
	var item_to_equip:Equipment = selected_slot.item_in_slot
	
	if item_to_equip.equipment_slot != hovered_slot.equipment_slot: return false
	if item_to_equip.equipment_slot != Equipment.EquipmentSlot.MAIN_HAND: return true
	if item_to_equip is Weapon:
		if item_to_equip.hand_type == Weapon.HandType.ONE_HANDED: return true
	
	#Now we know we are trying to equip a two handed weapon
	var item_in_mainhand:Equipment = equipment_slots[Equipment.EquipmentSlot.MAIN_HAND].item_in_slot
	var item_in_offhand:Equipment = equipment_slots[Equipment.EquipmentSlot.OFF_HAND].item_in_slot
	var empty_inv_space:int = 0
	for slot:InventorySlot in slots:
		if slot.item_in_slot == null and !slot.equipment_slot: empty_inv_space += 1

	#1 empty space required to unequip both hands
	if item_in_mainhand != null and item_in_offhand != null and empty_inv_space < 1:
		return false
	
	#Add off hand to inv and unequip
	add_item_to_inv(equipment_slots[Equipment.EquipmentSlot.OFF_HAND].item_in_slot)
	equipment_slots[Equipment.EquipmentSlot.OFF_HAND].remove_item()
	
	return true

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

	if !selected_slot: _show_tt(slot)
	slot.hover_slot()
	
func _clear_hover(slot:InventorySlot) -> void:
	if hovered_slot == slot: hovered_slot = null
	_hide_tt(slot)
	slot.unhover_slot()

func _show_tt(slot:InventorySlot) -> void:
	if slot.item_in_slot == null: return
	
	var tooltip:ItemTooltip = tooltips[slot.item_in_slot]
	tooltip.visible = true
	var offset_x:float = tooltip.get_tt_size().x
	var offset_y:float = (tooltip.get_tt_size().y - slot.size.y) / 2
	tooltips[slot.item_in_slot].global_position = slot.global_position - Vector2(offset_x + 15,offset_y)
	
func _hide_tt(slot:InventorySlot) -> void:
	if slot.item_in_slot == null: return
	
	tooltips[slot.item_in_slot].visible = false
