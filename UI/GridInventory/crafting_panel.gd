extends PanelContainer
class_name CraftingPanel

enum CraftAction {REMOVE_RAND_AFF,REMOVE_SPEF_AFF, ADD_AFF, ADD_ILVL, ADD_MAX_AFF, NOTHING}

@export var inventory_panel:InventoryPanel = null
@export var crafting_equipment_square: EquipmentSquare
@export var affix_container: VBoxContainer

const AFF_PAN_SCENE:PackedScene = preload("res://Tile-RPG/UI/Crafting/affix_panel.tscn")

var crafting_equipment:Equipment = null
var equ_tt:ItemTooltip = null
var hovered_ap:AffixPanel = null
var action:CraftAction = CraftAction.NOTHING

var setting_on_crafting_square:bool = false

func _ready() -> void:
	crafting_equipment_square.inventory_panel = inventory_panel
	crafting_equipment_square.mouse_entered.connect(func(): setting_on_crafting_square = true)
	crafting_equipment_square.mouse_exited.connect(func(): setting_on_crafting_square = false)
	await get_tree().process_frame
	
	#var eq:Equipment = ItemGenerator.get_equipment()
	#var inv_item:InventoryItem = inventory_panel._get_inventory_item(eq)
	#inv_item.show()
	#set_inv_item_on_crafting_square(inv_item)

func remove_inv_item_on_crafting_square() -> void:
	crafting_equipment_square.inventory_item_in_square = null

func set_inv_item_on_crafting_square(inv_item_to_craft:InventoryItem) -> void:
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

func _add_affix_panels(aff_array:Array[Affix]) -> void:
	for aff:Affix in aff_array:
		_add_affix_pan(aff)

func _add_affix_pan(aff:Affix) -> void:
	var new_aff_panel:AffixPanel = AFF_PAN_SCENE.instantiate()
	affix_container.add_child(new_aff_panel)
	new_aff_panel.set_affix(aff)
	
	new_aff_panel.mouse_entered.connect(_ap_hovered.bind(new_aff_panel))
	new_aff_panel.mouse_exited.connect(_ap_exited.bind(new_aff_panel))
	
func _ap_hovered(ap:AffixPanel) -> void:
	hovered_ap = ap
	var to_delete:bool = false
	if action == CraftAction.REMOVE_SPEF_AFF: to_delete = true
	hovered_ap.show_glow(to_delete)
	
func _ap_exited(ap:AffixPanel) -> void:
	if hovered_ap == ap: hovered_ap = null
	ap.hide_glow()
