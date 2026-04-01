extends Control
class_name Inventory

signal sell_item(item:Item)

@onready var inv_slot_grid: GridContainer = %InvSlotGrid
@onready var equipment_grid: GridContainer = %EquipmentGrid
@onready var x_button: XButton = $x_button
@onready var throw_out_area: Control = $ThrowOutArea
@export var currency_amount_label: Label = null

const INV_SIZE:int = 15
const INV_SLOT_PATH:String = "res://Tile-RPG/UI/Inventory/inventory_slot.tscn"
const ITEM_TT_PATH:String = "res://Tile-RPG/UI/Inventory/item_tooltip.tscn"
const INV_DROP:AudioStream = preload("uid://c0naiqt18dbxq")
const INV_PICK:AudioStream = preload("uid://t4n17ysxkboc")
const BG_DICT:Dictionary[Equipment.EquipmentSlot, Texture2D] = {
	Equipment.EquipmentSlot.NECK: preload("uid://cs7enw4chf7o0"),
	Equipment.EquipmentSlot.CHEST: preload("uid://csuvdo1xfmrlo"),
	Equipment.EquipmentSlot.WAIST: preload("uid://545xjkc3bbhb"),
	Equipment.EquipmentSlot.FEET: preload("uid://disvj6dguw7rx"),
	Equipment.EquipmentSlot.HANDS: preload("uid://bjhhk8qdavghl"),
	Equipment.EquipmentSlot.HEAD: preload("uid://ccukvnuyioqtf"),
	Equipment.EquipmentSlot.MAIN_HAND: preload("uid://hfbqojp8uoo8"),
	Equipment.EquipmentSlot.OFF_HAND: preload("uid://bke5ek62sccvo"),
	Equipment.EquipmentSlot.FINGER: preload("uid://cbw5exe7le1dn")}
const EQU_CORNER:Texture2D = preload("uid://buhoav5pguorp")
const GROUND_DROP := preload("uid://cuocgxmrrsjwt")

var player:Player = null
var player_inv_slots:Array[InventorySlot] = []
var slots:Array[InventorySlot] = []
var equipment_slots:Dictionary[Equipment.EquipmentSlot,InventorySlot] = {}  
var tooltips:Dictionary[Item,ItemTooltip] = {}

var slots_generated:bool = false
var hovered_slot:InventorySlot = null
var selected_slot:InventorySlot = null
var old_slot_pos:Vector2 = Vector2.ZERO
var img_offset:int = 0
var drop_item_on_release:bool = false
var sell_item_on_release:bool = false
var player_currency:int = 555:
	set(value):
		player_currency = max(0, value)
		_update_currency_amount(player_currency)

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	visibility_changed.connect(_on_vis_change)
	
	x_button.x_pressed.connect(func(): self.visible = false)
	throw_out_area.mouse_entered.connect(func(): drop_item_on_release = true)
	throw_out_area.mouse_exited.connect(func(): drop_item_on_release = false)

func _on_vis_change() -> void:
	if visible:
		set_process(true)
		set_process_input(true)
	else:
		set_process(false)
		set_process_input(false)

func _drop_item() -> bool:
	if !drop_item_on_release: return false
	var selected_item:Item = selected_slot.item_in_slot
	if selected_item == null: return false
	
	#Only drop items from player inv
	if !player_inv_slots.has(selected_slot) and !equipment_slots.values().has(selected_slot):
		return false
	
	var new_ground_drop:GroundDrop = GROUND_DROP.instantiate()
	new_ground_drop.set_item(selected_item)
	GlobalSignals.current_level.add_child(new_ground_drop)
	new_ground_drop.global_position = player.global_position + Vector3(0,0.5,0)
	new_ground_drop.shoot_rigidbody()
	
	return true

func set_player(new_player:Player) -> void:
	player = new_player
	if slots_generated: return
	
	_add_inv_slots()
	_add_equipment_slots()
	slots_generated = true
	
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
		var script: Script = load(save_data["equipment"][slot]["item_type"])
		var loaded_equ:Equipment = script.new()
		loaded_equ.load_from_data(save_data["equipment"][slot])
		_create_item_tt(loaded_equ)
		loaded_equ.remake_tt.connect(_remake_tt.bind(loaded_equ))
		
		player.equipment_handler.set_handler_owner()
		#Don't equip gear again, stats are saved with gear equipped
		var skip_equipping:bool = true
		player.equipment_handler.equip_item(loaded_equ, skip_equipping)
		equipment_slots[slot].set_item(loaded_equ,null,skip_equipping)


func save_inv_to_data(save_data:Dictionary) -> void:
	var inv_data:Dictionary = {}
	
	for islot:InventorySlot in slots:
		if islot.array_pos != -1 and islot.item_in_slot != null:
			inv_data[islot.array_pos] = islot.item_in_slot.save_to_data()
			
	save_data["inventory"] = inv_data
	_save_equipment(save_data)

func _update_currency_amount(amount:int) -> void:
	currency_amount_label.text = str(amount)

func _load_currency(save_data:Dictionary) -> void:
	if !save_data["quest_handler"].has("player_currency"): return
	
	player_currency = save_data["quest_handler"]["player_currency"]

func load_inv_from_data(save_data:Dictionary) -> void:
	if !save_data.has("inventory"): return
	_load_currency(save_data)

	for key:int in save_data["inventory"].keys():
		var script: Script = load(save_data["inventory"][key]["item_type"])
		var loaded_item:Item = script.new()

		loaded_item.load_from_data(save_data["inventory"][key])
		loaded_item.remake_tt.connect(_remake_tt.bind(loaded_item))
		slots[key].set_item(loaded_item)
		_create_item_tt(loaded_item)
	
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

func _restore_equ_slot_bg(slot:InventorySlot) -> void:
	slot.bg_image.texture = BG_DICT[slot.equipment_slot]

func _add_equipment_slots() -> void:
	var equ_slots:Array[Equipment.EquipmentSlot] =[
		Equipment.EquipmentSlot.NECK, Equipment.EquipmentSlot.HEAD,Equipment.EquipmentSlot.FINGER,
		Equipment.EquipmentSlot.HANDS, Equipment.EquipmentSlot.CHEST, Equipment.EquipmentSlot.FEET,
		Equipment.EquipmentSlot.MAIN_HAND, Equipment.EquipmentSlot.WAIST, Equipment.EquipmentSlot.OFF_HAND]
	
	for slot:Equipment.EquipmentSlot in equ_slots:
		var new_inv_slot:InventorySlot = load(INV_SLOT_PATH).instantiate()
		var equ_bg_texture:Texture2D = BG_DICT[slot]
		new_inv_slot.put_back_equ_bg.connect(_restore_equ_slot_bg.bind(new_inv_slot))
		
		new_inv_slot.bg_image.texture = equ_bg_texture
		new_inv_slot.corner_image.texture = EQU_CORNER
		
		new_inv_slot.equipment_slot = slot
		equipment_grid.add_child(new_inv_slot)
		slots.push_back(new_inv_slot)
		equipment_slots[slot] = new_inv_slot
		new_inv_slot.custom_minimum_size = Vector2(140,140)
		
		new_inv_slot.equip_item.connect(player.equipment_handler.equip_item)
		new_inv_slot.unequip_item.connect(player.equipment_handler.unequip_item)
		new_inv_slot.mouse_exited.connect(_clear_hover.bind(new_inv_slot))
		new_inv_slot.mouse_entered.connect(_slot_hovered.bind(new_inv_slot))

func connect_slot(new_slot:InventorySlot) -> void:
	slots.push_back(new_slot)
	new_slot.mouse_exited.connect(_clear_hover.bind(new_slot))
	new_slot.mouse_entered.connect(_slot_hovered.bind(new_slot))
	
func remove_slot(slot_to_remove:InventorySlot) -> void:
	slots.erase(slot_to_remove)
	slot_to_remove.mouse_exited.disconnect(_clear_hover)
	slot_to_remove.mouse_entered.disconnect(_slot_hovered)

func add_item_to_inv(new_item:Item) -> bool:
	if new_item == null:
		print("ERROR TRYING TO ADD NULL ITEM TO INV")
		return false

	for slot:InventorySlot in slots:
		if slot.item_in_slot != null or slot.equipment_slot or slot.array_pos >= INV_SIZE: continue
		slot.set_item(new_item)
		_create_item_tt(new_item)
		
		if not new_item.remake_tt.is_connected(_remake_tt.bind(new_item)):
			new_item.remake_tt.connect(_remake_tt.bind(new_item))
			
		return true

	return false

func _remake_tt(remake_item:Equipment) -> void:
	tooltips[remake_item].generate_tooltip(remake_item)

func remove_item_from_inv(remove_item:Item) -> void:
	for slot:InventorySlot in player_inv_slots:
		if slot.item_in_slot == remove_item:
			tooltips[remove_item].queue_free()
			tooltips.erase(remove_item)
			slot.remove_item()

func _create_item_tt(new_item:Item) -> void:
	var new_tooltip:ItemTooltip = load(ITEM_TT_PATH).instantiate()
	new_tooltip.visible = false
	add_child(new_tooltip)
	new_tooltip.generate_tooltip(new_item)
	
	tooltips[new_item] = new_tooltip


func _item_clicked() -> void:
	if hovered_slot.item_in_slot == null: return
	if hovered_slot.dragging_disabled: return
	
	GlobalSignals.play_audio.emit(INV_PICK, AudioManager.AUDIO_TYPE.SOUND_EFFECT)
	_hide_tt(hovered_slot)
	old_slot_pos = hovered_slot.item_image.global_position
	selected_slot = hovered_slot
	img_offset = int(selected_slot.item_image.get_size().x / 2)
	selected_slot.item_image.z_index = 1
	
	#Enables mouse entered/exited signals to be fired when dragging item
	selected_slot.item_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _reset_selecting() -> void:
	if selected_slot == null: return
	selected_slot.item_image.z_index = 0
	selected_slot.item_image.global_position = old_slot_pos
	selected_slot = null

func _item_released() -> void:
	if selected_slot == null: return
	
	if _drop_item():
		selected_slot.remove_item()
		selected_slot = null
		return
		
	if sell_item_on_release:
		sell_item.emit(selected_slot.item_in_slot)
		_reset_selecting()
		return
	
	#Hovering over nothing or own slot
	if hovered_slot == null or hovered_slot == selected_slot or !_possible_to_equip():
		_reset_selecting()
		return
	
	if hovered_slot.dragging_disabled:
		_reset_selecting()
		return
	
	GlobalSignals.play_audio.emit(INV_DROP, AudioManager.AUDIO_TYPE.SOUND_EFFECT)
	selected_slot.item_image.global_position = old_slot_pos
	hovered_slot.set_item(selected_slot.item_in_slot,selected_slot)
	selected_slot = null

func get_empty_item_space() -> int:
	var empty_inv_space:int = 0
	for slot:InventorySlot in slots:
		if slot.item_in_slot == null and !slot.equipment_slot: empty_inv_space += 1
		
	return empty_inv_space

#Equipping a two handed weapon requires unequipping off and mainhand
func _possible_to_equip() -> bool:
	if !hovered_slot.equipment_slot: return true
	if !player.equipment_handler.can_equip(): return false
	
	var item_to_equip:Equipment = selected_slot.item_in_slot
	var item_in_mainhand:Weapon = equipment_slots[Equipment.EquipmentSlot.MAIN_HAND].item_in_slot
	var item_in_offhand:Equipment = equipment_slots[Equipment.EquipmentSlot.OFF_HAND].item_in_slot
	
	#if wieldin 2H and trying to equip shield
	if item_to_equip.equipment_slot == Equipment.EquipmentSlot.OFF_HAND and item_in_mainhand != null:
		if item_in_mainhand.hand_type ==  Weapon.HandType.TWO_HANDED: return false
	
	if item_to_equip.equipment_slot != hovered_slot.equipment_slot: return false
	if item_to_equip.equipment_slot != Equipment.EquipmentSlot.MAIN_HAND: return true
	if item_to_equip is Weapon:
		if item_to_equip.hand_type == Weapon.HandType.ONE_HANDED: return true
	
	#Now we know we are trying to equip a two handed weapon
	var empty_inv_space:int = get_empty_item_space()

	#2 empty space required to unequip both hands
	if item_in_mainhand != null and item_in_offhand != null and empty_inv_space < 2:
		return false
	
	#Add off hand to inv and unequip
	var offhand_item:Equipment = equipment_slots[Equipment.EquipmentSlot.OFF_HAND].item_in_slot
	if offhand_item != null:
		add_item_to_inv(offhand_item)
		equipment_slots[Equipment.EquipmentSlot.OFF_HAND].remove_item()
	
	return true

func _add_inv_slots() -> void:
	for i:int in INV_SIZE:
		var new_slot:InventorySlot = load(INV_SLOT_PATH).instantiate()
		new_slot.array_pos = i
		inv_slot_grid.add_child(new_slot)
		connect_slot(new_slot)
		player_inv_slots.push_back(new_slot)

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
	if slot.array_pos <= -2: return
	
	var tooltip:ItemTooltip = tooltips[slot.item_in_slot]
	tooltip.visible = true
	
	var offset_x:float = tooltip.get_tt_size().x
	var offset_y:float = (tooltip.get_tt_size().y - slot.size.y) / 2
	
	#Show TT on slot right side instead of left
	if slot.array_pos >= INV_SIZE:
		pass
	
	if slot.array_pos >= INV_SIZE:
		tooltip.global_position = slot.global_position + Vector2(slot.size.x + 15, -offset_y)
	else:
		tooltip.global_position = slot.global_position - Vector2(offset_x + 15, offset_y)
	
func _hide_tt(slot:InventorySlot) -> void:
	if slot.item_in_slot == null: return
	if slot.array_pos <= -2: return
	
	tooltips[slot.item_in_slot].visible = false
