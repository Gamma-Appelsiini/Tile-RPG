extends Control
class_name LootWindow

@onready var container_name: Label = %ContainerName
@onready var grid_container: GridContainer = %GridContainer
@onready var container_image: TextureRect = %ContainerImage
@export var player_inventory:Inventory = null
@export var x_button: XButton = null
@export var wood_bg: TextureRect = null
@export var panel_container: PanelContainer = null

const LOOT_SIZE:int = 10
const INV_SLOT_SCENE:PackedScene = preload("res://Tile-RPG/UI/Inventory/inventory_slot.tscn")
const BORDER_TEXTURES:Dictionary[LootContainer.ContainerStyle, Texture2D] = {LootContainer.ContainerStyle.WOOD: preload("uid://dfxc2i7p6w3ay")}

var style_dict:Dictionary[LootContainer.ContainerStyle, TextureRect] = {}
var inv_slots:Array[InventorySlot] = []
var loot_container:LootContainer = null

func _ready() -> void:
	_add_slots()
	GlobalSignals.show_container.connect(add_container)
	x_button.x_pressed.connect(_close_window)
	style_dict[LootContainer.ContainerStyle.WOOD] = wood_bg

func _connect_slots() -> void:
	for slot:InventorySlot in inv_slots:
		slot.item_placed.connect(_item_added_to_container)
		
	for slot:InventorySlot in player_inventory.slots:
		if slot.array_pos >= player_inventory.INV_SIZE: continue
		slot.item_placed.connect(_item_added_to_inv)

func _add_slots() -> void:
	var pos:int = player_inventory.INV_SIZE
	for i:int in LOOT_SIZE:
		var new_slot:InventorySlot = INV_SLOT_SCENE.instantiate()
		new_slot.array_pos = pos + i
		
		grid_container.add_child(new_slot)
		player_inventory.connect_slot(new_slot)
		inv_slots.push_back(new_slot)

func _item_added_to_inv(new_item:Item) -> void:
	if loot_container.items.has(new_item):
		loot_container.remove_item(new_item)
		loot_container.set_highest_rarity()

func _item_added_to_container(new_item:Item) -> void:
	loot_container.add_item(new_item)
	loot_container.set_highest_rarity()

func add_container(container:LootContainer) -> void:
	loot_container = container
	container_name.text = container.container_name
	if container.container_image: container_image.texture = container.container_image
	
	for item:Item in container.items:
		_add_item(item)
	
	_connect_slots()
	self.visible = true
	player_inventory.visible = true
	
	_set_panel_borders(container.container_style)
	_show_style_bg(container.container_style)

func _add_item(item:Item) -> void:
	for slot:InventorySlot in inv_slots:
		if slot.item_in_slot != null: continue
		
		slot.set_item(item)
		player_inventory._create_item_tt(item)
		return
	
func _clear_container() -> void:
	for slot:InventorySlot in inv_slots:
		slot.item_placed.disconnect(_item_added_to_container)
		slot.remove_item()
		
	for slot:InventorySlot in player_inventory.slots:
		if slot.array_pos >= player_inventory.INV_SIZE: continue
		slot.item_placed.disconnect(_item_added_to_inv)

func _close_window() -> void:
	self.visible = false
	player_inventory.visible = false
	_clear_container()
	GlobalSignals.close_container.emit(loot_container)

func _show_style_bg(style:LootContainer.ContainerStyle) -> void:
	for key:LootContainer.ContainerStyle in style_dict.keys():
		if key == style: style_dict[key].show()
		else: style_dict[key].hide()

func _set_panel_borders(style:LootContainer.ContainerStyle):
	var stylebox: StyleBoxTexture = panel_container.get_theme_stylebox("panel")
	stylebox.texture = BORDER_TEXTURES[style]
