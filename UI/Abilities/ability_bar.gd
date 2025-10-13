extends Control
class_name AbilityBar

@export var ability_slot_container: HBoxContainer = null
@export var ability_targeter:AbilityTargeter = null

var slots:Array[AbilitySlot] = []
var hovered_slot:AbilitySlot = null
var player:Player = null
var selected_ability:Ability = null
const BASIC_ATTACK = preload("uid://bs08mf1jnw3vi")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_slot_pressed()

func set_player(new_player:Player) -> void:
	player = new_player

func _ready() -> void:
	set_process_input(true)
	for abi_slot:AbilitySlot in ability_slot_container.get_children():
		slots.push_back(abi_slot)
		abi_slot.ability_hovered.connect(_set_hovered_slot)
		
	test()
	
func test() -> void:
	var new_ability:Ability = BASIC_ATTACK.instantiate()
	slots[0].set_ability(new_ability)

func _set_hovered_slot(new_slot:AbilitySlot) -> void:
	hovered_slot = new_slot
	
func _clear_hovered_slot(new_slot:AbilitySlot) -> void:
	if hovered_slot == new_slot: hovered_slot = null

func _slot_pressed() -> void:
	if hovered_slot == null:
		print("hovered_slot == null")
		return
	selected_ability = hovered_slot.ability_in_slot
	if selected_ability == null:
		print("selected_ability == null")
		return
	
	ability_targeter.set_ability_to_target(selected_ability)

func hide_bar() -> void:
	set_process_input(false)
	self.visible = false
	
func show_bar() -> void:
	set_process_input(true)
	self.visible = true
