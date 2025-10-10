extends PanelContainer
class_name AbilityBar

@export var ability_slot_container: HBoxContainer = null

var slots:Array[Ability] = []
var hovered_slot:AbilitySlot = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_slot_pressed()

func _ready() -> void:
	set_process_input(false)
	for abi_slot:AbilitySlot in ability_slot_container.get_children():
		slots.push_back(abi_slot)
		abi_slot.ability_hovered.connect(_set_hovered_slot)
		
func _set_hovered_slot(new_slot:AbilitySlot) -> void:
	hovered_slot = new_slot
	
func _clear_hovered_slot(new_slot:AbilitySlot) -> void:
	if hovered_slot == new_slot: hovered_slot = null

func _slot_pressed() -> void:
	if hovered_slot == null: return

func hide_bar() -> void:
	set_process_input(false)
	self.visible = false
	
func show_bar() -> void:
	set_process_input(true)
	self.visible = true
