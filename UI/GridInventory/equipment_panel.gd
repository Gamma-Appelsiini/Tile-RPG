extends PanelContainer
class_name EquipmentPanel

@export var inventory_panel:InventoryPanel = null

var equipment_squares:Dictionary[Equipment.EquipmentSlot, EquipmentSquare] = {}
var hovered_equipment_square:EquipmentSquare = null

func _ready() -> void:
	_add_equipment_squares(self)
	print(len(equipment_squares.keys()))
	
func _add_equipment_squares(ui_node:Control) -> void:
	for child:Control in ui_node.get_children():
		if child is not EquipmentSquare: _add_equipment_squares(child)
		elif child is EquipmentSquare:
			child.inventory_panel = inventory_panel
			equipment_squares[child.equipment_slot] = child
			
			child.mouse_entered.connect(func(): hovered_equipment_square = child)
			child.mouse_exited.connect(func(): hovered_equipment_square = null)
