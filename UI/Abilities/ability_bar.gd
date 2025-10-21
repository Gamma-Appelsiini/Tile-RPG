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
	if visible: return
	#TODO animate
	self.visible = true

func _on_container_mouse_entered() -> void:
	set_process_input(true)

func _on_container_mouse_exited() -> void:
	set_process_input(false)

func save_to_data() -> Array:
	var save_array:Array[String] = []
	
	for slot:AbilitySlot in slots:
		var abi_to_save:Ability = slot.ability_in_slot
		if abi_to_save == null: save_array.push_back("")
		else:
			var scene_path:String = abi_to_save.scene_file_path
			save_array.push_back(scene_path)
		
	return save_array

func load_from_array(save_array:Array[String]) -> void:
	if save_array == []: return
	
	var place:int = 0
	for path:String in save_array:
		if path != "":
			var new_ability:Ability = load(path).instantiate()
			new_ability.ability_owner = player
			slots[place].set_ability(new_ability)
		place += 1
