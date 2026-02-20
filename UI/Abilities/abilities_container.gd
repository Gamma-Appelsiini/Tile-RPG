extends Control
class_name AbilitiesContainer

@export var grid_container: GridContainer = null
@export var ability_bar:AbilityBar = null
@export var x_button: XButton = null

const SLOTS:int = 6 * 5
const ABILITY_SLOT := preload("uid://camo5qmy5xx2a")
const ABILITY_TOOLTIP := preload("uid://dwwbtybjbkw7p")

var owned_abilities:Array[Ability] = []
var hovered_slot:AbilitySlot = null
var hovered_bar_slot:AbilitySlot = null
var clicked_slot:AbilitySlot = null
var original_pos:Vector2 = Vector2.ZERO
const BASIC_ATTACK = preload("uid://bs08mf1jnw3vi")
const FIREBALL = preload("uid://def83grj4ohmj")
const ICE_BOLT = preload("uid://7xc2gc31hgti")
const EVASION_BUFFER := preload("uid://wct51sa62ho1")
const SKY_HAMMER := preload("uid://3uev06m0wx45")

var tooltip:AbilityTooltip = null

func _ready() -> void:
	set_process_input(false)
	set_process(false)
	x_button.x_pressed.connect(hide_container)
	
	_create_tooltip()
	
	for i in SLOTS:
		var new_slot:AbilitySlot = ABILITY_SLOT.instantiate()
		grid_container.add_child(new_slot)
		new_slot.ability_hovered.connect(set_hovered)
		new_slot.ability_unhovered.connect(set_hovered)
		new_slot.tooltip = self.tooltip
		
	for slot:AbilitySlot in ability_bar.slots:
		slot.ability_hovered.connect(set_hovered)
		slot.ability_unhovered.connect(set_hovered)
		slot.tooltip = self.tooltip

func _create_tooltip() -> void:
	var new_tt:AbilityTooltip = ABILITY_TOOLTIP.instantiate()
	tooltip = new_tt
	new_tt.visible = false
	add_child(new_tt)

func set_player(new_player:Player) -> void:
	var new_ability:Ability = BASIC_ATTACK.instantiate()
	new_ability.ability_owner = new_player
	add_new_ability(new_ability)
	
	var new_ability2:Ability = FIREBALL.instantiate()
	new_ability2.ability_owner = new_player
	add_new_ability(new_ability2)
	
	var new_ability3:Ability = ICE_BOLT.instantiate()
	new_ability3.ability_owner = new_player
	add_new_ability(new_ability3)
	
	var new_ability4:Ability = EVASION_BUFFER.instantiate()
	new_ability4.ability_owner = new_player
	add_new_ability(new_ability4)
	
	var new_ability5:Ability = SKY_HAMMER.instantiate()
	new_ability5.ability_owner = new_player
	add_new_ability(new_ability5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_slot_pressed()
	elif event.is_action_released("Left Click"):
		_slot_released()

func _slot_pressed() -> void:
	if hovered_slot == null: return
	if hovered_slot.ability_in_slot == null: return
	
	clicked_slot = hovered_slot
	clicked_slot.ability_icon_rect.z_index = 1
	original_pos = hovered_slot.ability_icon_rect.global_position
	set_process(true)
	
func _slot_released() -> void:
	if clicked_slot == null: return
	set_process(false)
	
	if hovered_bar_slot != null:
		hovered_bar_slot.set_ability(clicked_slot.ability_in_slot)
	
	clicked_slot.ability_icon_rect.z_index = 0
	clicked_slot.ability_icon_rect.global_position = original_pos
	clicked_slot = null

func _process(_delta: float) -> void:
	clicked_slot.ability_icon_rect.global_position = get_global_mouse_position()

func add_new_ability(new_ability:Ability) -> bool:
	for abi:Ability in owned_abilities:
		if abi.ability_name == new_ability.ability_name: return false
		
	owned_abilities.push_back(new_ability)
	for slot:AbilitySlot in grid_container.get_children():
		if slot.ability_in_slot == null:
			slot.set_ability(new_ability)
			break
	
	new_ability.connect_signals()
	return true

func set_hovered(slot:AbilitySlot) -> void:
	if slot in ability_bar.slots:
		hovered_bar_slot = slot
		return
	hovered_slot = slot
	
func set_unhovered(slot:AbilitySlot) -> void:
	if slot in ability_bar.slots:
		hovered_bar_slot = null
		return
	if hovered_slot == slot: hovered_slot = null

func show_container() -> void:
	visible = true
	set_process_input(true)
	ability_bar.show_bar()
	
func hide_container() -> void:
	visible = false
	set_process_input(false)
	#TODO check if in combat
	ability_bar.hide_bar()
	
func save_to_data(save_data:Dictionary) -> void:
	var save_array:Array[String] = []
	
	for slot:AbilitySlot in grid_container.get_children():
		var abi_to_save:Ability = slot.ability_in_slot
		if abi_to_save == null: break
		else:
			var scene_path:String = abi_to_save.scene_file_path
			save_array.push_back(scene_path)
			
	save_data["abilities_container"] = save_array

func load_from_data(save_data:Dictionary) -> void:
	var save_array:Array[String] = save_data["abilities_container"]
	if save_array == []: return
	
	for path:String in save_array:
		var new_ability:Ability = load(path).instantiate()
		add_new_ability(new_ability)
