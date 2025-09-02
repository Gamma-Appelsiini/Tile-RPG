extends Interactable
class_name Anvil

@onready var crafting_window: CraftinWindow = %CraftingWindow

var player_inv:Inventory = null

func _ready() -> void:
	_on_creation()
	crafting_window.visible = false
	crafting_window.window_closed.connect(_crafting_closed)
	player_inv = get_tree().get_nodes_in_group("Inventory")[0]

func interact() -> void:
	_connect_cw_slot_to_inv()
	
	player.movement_enabled = false
	crafting_window.visible = true
	player_inv.visible = true
	interact_area.monitoring = false

func _connect_cw_slot_to_inv() -> void:
	crafting_window.inventory_slot.array_pos = -2
	player_inv.connect_slot(crafting_window.inventory_slot)

func _remove_cw_slot_from_inv() -> void:
	player_inv.remove_slot(crafting_window.inventory_slot)

func _add_crafted_item_back_to_inv() -> void:
	if !crafting_window.crafting_equipment: return
	
	var added:bool = player_inv.add_item_to_inv(crafting_window.crafting_equipment)
	if added: crafting_window.clear_equ()

func _crafting_closed() -> void:
	_remove_cw_slot_from_inv()
	_add_crafted_item_back_to_inv()
	
	crafting_window.visible = false
	player_inv.visible = false
	player.movement_enabled = true
	interact_area.monitoring = true
