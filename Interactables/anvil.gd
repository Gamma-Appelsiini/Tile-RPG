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

func _crafting_closed() -> void:
	if ui_handler.crafting_window.visible:
		ui_handler.crafting_window.visibility_changed.connect(_crafting_closed, CONNECT_ONE_SHOT)
		return
	
	ui_handler.inventory.crafting_window_open = false
	interact_complete.emit()
