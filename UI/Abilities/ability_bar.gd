extends Control
class_name AbilityBar

@export var ability_slot_container: HBoxContainer = null
@export var ability_targeter:AbilityTargeter = null
@export var panel_container: PanelContainer = null
@export var ap_container: ApContainer = null
@export var color_rect: ColorRect = null
@export var button_container: MarginContainer = null
@export var info_container: HBoxContainer = null
@export var movement_label: Label = null
@export var input_area: Control = null
@export var end_turn_button: Button = null
@export var xp_bar: XpPanel = null

@export var end_turn_button_sound:AudioStream = null

const ABILITY_TOOLTIP := preload("uid://dwwbtybjbkw7p")

var controls:Array[bool] = []
var slots:Array[AbilitySlot] = []
var hovered_slot:AbilitySlot = null
var player:Player = null
var selected_ability:Ability = null
var in_combat:bool = false
var bind_slot_dict:Dictionary[String, AbilitySlot] = {}
var ability_tooltip:AbilityTooltip = null

func _unhandled_input(event: InputEvent) -> void:
	for action:String in bind_slot_dict.keys():
		if event.is_action_pressed(action):
			_ability_slot_pressed(bind_slot_dict[action])

func set_player(new_player:Player) -> void:
	player = new_player
	ap_container.set_player(new_player)
	player.start_turn.connect(_on_turn_start)
	player.end_turn.connect(_on_turn_end)
	player.stat_handler.stats_changed.connect(_set_movement)
	
	xp_bar.set_stat_handler(player.stat_handler)

func _ready() -> void:
	set_process_unhandled_input(false)
	_connect_signals()
	_create_tooltip()
	_add_slots()

func _create_tooltip() -> void:
	var new_tt:AbilityTooltip = ABILITY_TOOLTIP.instantiate()
	ability_tooltip = new_tt
	new_tt.visible = false
	add_child(new_tt)

func _add_slots() -> void:
	var number:int = 1
	for abi_slot:AbilitySlot in ability_slot_container.get_children():
		slots.push_back(abi_slot)
		
		abi_slot.button.pressed.connect(_ability_slot_pressed.bind(abi_slot))
		abi_slot.tooltip = ability_tooltip
		
		if number == 10: number = 0
		abi_slot.set_number(number)
		bind_slot_dict["ability " + str(number)] = abi_slot
		number += 1

func _ability_slot_pressed(pressed_slot:AbilitySlot) -> void:
	if !in_combat or color_rect.visible: return
	selected_ability = pressed_slot.ability_in_slot
	
	if selected_ability != null:
		if !selected_ability.has_required_weapon_type():
			#TODO visual indication
			print_debug("selected_ability not compatible weapon")
			ability_targeter.cancel_ability_targeting()
			return
		if !selected_ability._is_enough_resources():
			#TODO visual indication
			print_debug("selected_ability not enought resources")
			ability_targeter.cancel_ability_targeting()
			return

	ability_targeter.set_ability_to_target(pressed_slot)

func _connect_signals() -> void:
	GlobalSignals.combat_start.connect(func(): in_combat = true)
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	
	GlobalSignals.combat_start.connect(func(): info_container.visible = true)
	GlobalSignals.combat_end.connect(func(): info_container.visible = false)
	
	GlobalSignals.combat_start.connect(func(): set_process_unhandled_input(true))
	GlobalSignals.combat_end.connect(func(): set_process_unhandled_input(false))
	
	GlobalSignals.combat_end.connect(color_rect.show)

func _set_movement() -> void:
	movement_label.text = str(player.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT])

func _on_turn_start() -> void:
	color_rect.hide()
	button_container.show()
	
func _on_turn_end() -> void:
	button_container.hide()
	color_rect.show()

func _set_hovered_slot(new_slot:AbilitySlot) -> void:
	hovered_slot = new_slot
	
func _clear_hovered_slot(new_slot:AbilitySlot) -> void:
	if hovered_slot == new_slot: hovered_slot = null

func hide_bar() -> void:
	#TODO animate
	self.visible = false
	info_container.hide()
	
func show_bar() -> void:
	if visible: return
	#TODO animate
	self.visible = true
	if in_combat: info_container.show()

func save_to_data() -> Array:
	var save_array:Array[String] = []
	
	for slot:AbilitySlot in slots:
		var abi_to_save:Ability = slot.ability_in_slot
		if abi_to_save == null: save_array.push_back("")
		else:
			var scene_path:String = abi_to_save.scene_file_path
			save_array.push_back(scene_path)
		
	return save_array

func load_from_array(save_array:Array) -> void:
	if save_array == []: return
	
	var place:int = 0
	for path:String in save_array:
		if path != "":
			var new_ability:Ability = load(path).instantiate()
			new_ability.ability_owner = player
			slots[place].set_ability(new_ability)
		place += 1


func _on_end_turn_button_pressed() -> void:
	player.end_turn.emit()
	button_container.hide()
	GlobalSignals.play_audio.emit(end_turn_button_sound, AudioManager.AUDIO_TYPE.UI)
