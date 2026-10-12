extends PanelContainer
class_name EquipmentSquare

@export var inventory_panel:InventoryPanel = null
@export var equipment_slot:Equipment.EquipmentSlot = Equipment.EquipmentSlot.NECK
@export var hover_image: TextureRect
@export var cant_place_rect: TextureRect
@export var can_place_rect: TextureRect
@export var nine_patch_rect: NinePatchRect
@export var bg_image: TextureRect
@export var nine_patch_rect_2: NinePatchRect
@export var equipment_shadow: TextureRect

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

const IMAGES_DICT:Dictionary[Equipment.EquipmentSlot, Texture2D] = {
	Equipment.EquipmentSlot.MAIN_HAND: preload("uid://5atefkxyvq6y"),
	Equipment.EquipmentSlot.OFF_HAND: preload("uid://3m1t22wcqly1"),
	Equipment.EquipmentSlot.FEET: preload("uid://cn7tbthudfuvs"),
	Equipment.EquipmentSlot.HEAD: preload("uid://bmtxfiuwniily"),
	Equipment.EquipmentSlot.NECK: preload("uid://b7oruf0enhfp0"),
	Equipment.EquipmentSlot.FINGER: preload("uid://cb0al3lnjwqtk"),
	Equipment.EquipmentSlot.CHEST: preload("uid://bvhgydrw63csk"),
	Equipment.EquipmentSlot.HANDS: preload("uid://yy1id5s2nwij"),
	Equipment.EquipmentSlot.WAIST: preload("uid://ck0d57oab27qd"),
}
const EQUIPMENT_SHADOW_MATERIAL = preload("uid://bar4g23n8ss8u")

var inventory_item_in_square:InventoryItem = null:
	set(value):
		if inventory_item_in_square == value: return
			
		if inventory_item_in_square:
			if inventory_item_in_square.mouse_entered.is_connected(hover_image.show):
				inventory_item_in_square.mouse_entered.disconnect(hover_image.show)
			if inventory_item_in_square.mouse_exited.is_connected(hover_image.hide):
				inventory_item_in_square.mouse_exited.disconnect(hover_image.hide)

			if inventory_item_in_square.hover_image_rect:
				inventory_item_in_square.hover_image_rect.modulate.a = 1
				
		inventory_item_in_square = value

		if !value:
			nine_patch_rect.z_index = 0
			nine_patch_rect_2.z_index = 0
			equipment_shadow.show()
		else:
			nine_patch_rect.z_index = 1
			nine_patch_rect_2.z_index = 1
			equipment_shadow.hide()
			
			if inventory_item_in_square.hover_image_rect: inventory_item_in_square.hover_image_rect.modulate.a = 0
				
			if not inventory_item_in_square.mouse_entered.is_connected(hover_image.show): inventory_item_in_square.mouse_entered.connect(hover_image.show)
			if not inventory_item_in_square.mouse_exited.is_connected(hover_image.hide): inventory_item_in_square.mouse_exited.connect(hover_image.hide)


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
	
	equipment_shadow.texture = IMAGES_DICT[equipment_slot]
	equipment_shadow.material = EQUIPMENT_SHADOW_MATERIAL
