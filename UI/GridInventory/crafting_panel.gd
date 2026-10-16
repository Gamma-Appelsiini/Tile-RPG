extends PanelContainer
class_name CraftingPanel

enum CraftAction {REMOVE_RAND_AFF,REMOVE_SPEF_AFF, ADD_AFF, ADD_ILVL, ADD_MAX_AFF, NOTHING}

@export var inventory_panel:InventoryPanel = null
@export var crafting_equipment_square: EquipmentSquare
@export var affix_container: VBoxContainer

const AFF_PAN_SCENE:PackedScene = preload("res://Tile-RPG/UI/Crafting/affix_panel.tscn")
const AFFIX_PANEL := preload("uid://du6la0lmqbrtj")

var crafting_equipment:Equipment = null
var equ_tt:ItemTooltip = null
var hovered_ap:AffixPanel = null
var action:CraftAction = CraftAction.NOTHING
var free_affix_panels:Array[AffixPanel] = []

var setting_on_crafting_square:bool = false

func _ready() -> void:
	crafting_equipment_square.inventory_panel = inventory_panel
	crafting_equipment_square.mouse_entered.connect(func(): setting_on_crafting_square = true)
	crafting_equipment_square.mouse_exited.connect(func(): setting_on_crafting_square = false)
	inventory_panel.hidden.connect(hide)
	
	_add_affix_panels()
	await get_tree().process_frame
	#hide()

func _on_vis_changed() -> void:
	if visible: return
	
	#Add item back to inv on close
	if crafting_equipment_square.inventory_item_in_square:
		if !inventory_panel._place_in_first_free_spot(crafting_equipment_square.inventory_item_in_square):
			inventory_panel._drop_item_on_ground(crafting_equipment_square.inventory_item_in_square)
	
	remove_inv_item_on_crafting_square()

func remove_inv_item_on_crafting_square() -> void:
	crafting_equipment_square.inventory_item_in_square = null
	crafting_equipment = null
	
	for affix_panel:AffixPanel in affix_container.get_children():
		affix_panel.hide()
		free_affix_panels.push_back(affix_panel)

func set_inv_item_on_crafting_square(inv_item_to_craft:InventoryItem) -> bool:
	if inv_item_to_craft.item is not Equipment: return false
	
	if inventory_panel.items_in_inventory.has(inv_item_to_craft):
		inventory_panel.items_in_inventory.erase(inv_item_to_craft)
	elif inventory_panel.items_equipped.keys().has(inv_item_to_craft):
		inventory_panel.items_equipped.erase(inv_item_to_craft)

	crafting_equipment_square.inventory_item_in_square = inv_item_to_craft
	inv_item_to_craft.global_position = crafting_equipment_square.global_position
	
	if crafting_equipment_square.size.x > inv_item_to_craft.size.x or crafting_equipment_square.size.y > inv_item_to_craft.size.y:
		inv_item_to_craft.global_position += Vector2((crafting_equipment_square.size.x - inv_item_to_craft.size.x) / 2,
		(crafting_equipment_square.size.y - inv_item_to_craft.size.y) / 2)
		
	inventory_panel.old_equipment_square_before_lifting = crafting_equipment_square
	crafting_equipment = inv_item_to_craft.item as Equipment
	
	_add_equipment_affixes(crafting_equipment.prefixes)
	_add_equipment_affixes(crafting_equipment.prefixes)
	_add_equipment_affixes(crafting_equipment.suffixes)
	_add_equipment_affixes(crafting_equipment.suffixes)
	return true

func _add_affix_panels() -> void:
	for number:int in 6:
		var new_affix_panel:AffixPanel = AFFIX_PANEL.instantiate()
		free_affix_panels.push_back(new_affix_panel)
		new_affix_panel.hide()
		affix_container.add_child(new_affix_panel)

func _add_equipment_affixes(affixes:Array[Affix]) -> void:
	for affix:Affix in affixes:
		var free_aff_panel:AffixPanel = free_affix_panels.pop_back()
		free_aff_panel.set_affix(affix)
		free_aff_panel.show()
