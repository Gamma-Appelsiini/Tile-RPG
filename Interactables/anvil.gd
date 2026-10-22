extends Interactable
class_name Anvil

var ui_handler:UIHandler = null

func _ready() -> void:
	_on_creation()

func interact() -> void:
	GlobalSignals.ui_handler.crafting_panel.anvil = self
	GlobalSignals.open_crafting.emit()
