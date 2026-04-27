extends Interactable
class_name Anvil

var ui_handler:UIHandler = null

func _ready() -> void:
	_on_creation()

func interact() -> void:
	ui_handler = GlobalSignals.ui_handler
	ui_handler.inventory.crafting_window_open = true
	GlobalSignals.open_crafting.emit()
	ui_handler.crafting_window.visibility_changed.connect(_crafting_closed, CONNECT_ONE_SHOT)

func _add_crafted_item_back_to_inv() -> void:
	pass
	#if !crafting_window.crafting_equipment: return
	
	#var added:bool = player_inv.add_item_to_inv(crafting_window.crafting_equipment)
	#if added: crafting_window.clear_equ()

func _crafting_closed() -> void:
	if ui_handler.crafting_window.visible:
		ui_handler.crafting_window.visibility_changed.connect(_crafting_closed, CONNECT_ONE_SHOT)
		return
	
	ui_handler.inventory.crafting_window_open = false
	interact_complete.emit()
