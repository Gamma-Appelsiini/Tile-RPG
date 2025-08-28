extends PanelContainer
class_name InventorySlot

signal equip_item(item:Equipment)
signal unequip_item(item:Equipment)

@onready var item_image: TextureRect = %ItemImage
@onready var hover_image: TextureRect = %HoverImage

var array_pos:int = -1
var item_in_slot:Item = null
var equipment_slot:Equipment.EquipmentSlot

func set_item(new_item:Item, old_slot:InventorySlot = null, skip_equipping:bool = false) -> void:
	if new_item == null:
		remove_item()
		return
	if old_slot != null:
		old_slot.set_item(item_in_slot)
	if item_in_slot != null: remove_item()
	
	if equipment_slot and !skip_equipping:
		equip_item.emit(new_item)

	item_image.texture = new_item.inventory_image
	item_in_slot = new_item

func remove_item() -> void:
	if equipment_slot:
		unequip_item.emit(item_in_slot.equipment_slot)

	item_image.texture = null
	item_in_slot = null

func hover_slot() -> void:
	hover_image.self_modulate.a = 1

func unhover_slot() -> void:
	hover_image.self_modulate.a = 0
