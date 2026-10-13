extends PanelContainer
class_name EquipmentPanel

@export var inventory_panel:InventoryPanel = null

var equipment_squares:Dictionary[Equipment.EquipmentSlot, EquipmentSquare] = {}
var hovered_equipment_square:EquipmentSquare = null

func _ready() -> void:
	_add_equipment_squares(self)
	
func _add_equipment_squares(ui_node:Control) -> void:
	for child:Control in ui_node.get_children():
		if child is not EquipmentSquare: _add_equipment_squares(child)
		elif child is EquipmentSquare:
			child.inventory_panel = inventory_panel
			equipment_squares[child.equipment_slot] = child
			
			child.mouse_entered.connect(func(): hovered_equipment_square = child)
			child.mouse_exited.connect(func(): hovered_equipment_square = null)

func save_equipment(save_data:Dictionary) -> void:
	var equ_data:Dictionary = {}
	
	for slot:Equipment.EquipmentSlot in equipment_squares.keys():
		var equ_to_save:Equipment = equipment_squares[slot].inv_item_in_square.item as Equipment
		if equ_to_save != null:
			equ_data[slot] = equ_to_save.save_to_data()
			
	save_data["equipment"] = equ_data

func load_equ_from_data(save_data:Dictionary) -> void:
	if !save_data.has("equipment"): return
	
	for square:Equipment.EquipmentSlot in save_data["equipment"].keys():
		var script: Script = load(save_data["equipment"][square]["item_type"])
		var loaded_equ:Equipment = script.new()
		loaded_equ.load_from_data(save_data["equipment"][square])
		
		GlobalSignals.player.equipment_handler.set_handler_owner()
		#Don't equip gear again, stats are saved with gear equipped
		var skip_equipping:bool = true
		GlobalSignals.player.equipment_handler.equip_item(loaded_equ, skip_equipping)
		
		var new_inv_item:InventoryItem = inventory_panel._get_inventory_item(loaded_equ)
		inventory_panel._set_inv_item_on_equipment_square(new_inv_item, equipment_squares[square])
