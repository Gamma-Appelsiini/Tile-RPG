extends PanelContainer
class_name EquipmentSquare

@export var inventory_panel:InventoryPanel = null
@export var equipment_slot:Equipment.EquipmentSlot = Equipment.EquipmentSlot.NECK
@export var hover_image: TextureRect
@export var cant_place_rect: TextureRect
@export var can_place_rect: TextureRect
@export var nine_patch_rect: NinePatchRect
@export var bg_image: TextureRect

const SIZES_DICT:Dictionary[Equipment.EquipmentSlot, Vector2i] = {
	Equipment.EquipmentSlot.MAIN_HAND: Vector2i(2,4),
	Equipment.EquipmentSlot.OFF_HAND: Vector2i(2,4),
	Equipment.EquipmentSlot.FEET: Vector2i(2,2),
	Equipment.EquipmentSlot.HEAD: Vector2i(2,2),
	Equipment.EquipmentSlot.NECK: Vector2i(1,1),
	Equipment.EquipmentSlot.FINGER: Vector2i(1,1),
	Equipment.EquipmentSlot.CHEST: Vector2i(2,3),
	Equipment.EquipmentSlot.HANDS: Vector2i(2,2),
	Equipment.EquipmentSlot.WAIST: Vector2i(2,1),
}

func _ready() -> void:
	self.mouse_entered.connect(func():
		if inventory_panel.lifted_inv_item:
			if inventory_panel.lifted_inv_item.item is Equipment:
				if inventory_panel.lifted_inv_item.item.equipment_slot != equipment_slot:
					cant_place_rect.show()
				else: can_place_rect.show()
			else: cant_place_rect.show()
		hover_image.show())
	self.mouse_exited.connect(func():
		hover_image.hide()
		cant_place_rect.hide()
		can_place_rect.hide()
		)
	_set_slot_size()

func _set_slot_size() -> void:
	var square_size:Vector2i = Vector2i(InventorySquare.SQUARE_SIZE * SIZES_DICT[equipment_slot].x, InventorySquare.SQUARE_SIZE * SIZES_DICT[equipment_slot].y)
	bg_image.custom_maximum_size = square_size
	bg_image.custom_minimum_size = square_size
