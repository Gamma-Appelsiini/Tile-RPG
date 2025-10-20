extends Control
class_name AbilityBar

@export var ability_slot_container: HBoxContainer = null
@export var ability_targeter:AbilityTargeter = null
@export var panel_container: PanelContainer = null

var slots:Array[AbilitySlot] = []
var hovered_slot:AbilitySlot = null
var player:Player = null
var selected_ability:Ability = null
const BASIC_ATTACK = preload("uid://bs08mf1jnw3vi")
const FIREBALL = preload("uid://def83grj4ohmj")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_slot_pressed()

func set_player(new_player:Player) -> void:
	player = new_player
	
	#Test
	var new_ability:Ability = BASIC_ATTACK.instantiate()
	new_ability.ability_owner = player
	slots[0].set_ability(new_ability)
	
	var new_ability2:Ability = FIREBALL.instantiate()
	new_ability2.ability_owner = player
	slots[1].set_ability(new_ability2)

func _ready() -> void:
	set_process_input(false)
	
	for abi_slot:AbilitySlot in ability_slot_container.get_children():
		slots.push_back(abi_slot)
		abi_slot.ability_hovered.connect(_set_hovered_slot)
		abi_slot.mouse_entered.connect(_on_container_mouse_entered)
		abi_slot.mouse_exited.connect(_on_container_mouse_exited)

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
	if !selected_ability._is_enough_resources():
		print("selected_ability not enought resources")
		return
	
	print("clicked; ", selected_ability.ability_name)
	ability_targeter.set_ability_to_target(selected_ability)

func hide_bar() -> void:
	#TODO animate
	self.visible = false
	
func show_bar() -> void:
	#TODO animate
	self.visible = true

func _on_container_mouse_entered() -> void:
	set_process_input(true)

func _on_container_mouse_exited() -> void:
	set_process_input(false)
