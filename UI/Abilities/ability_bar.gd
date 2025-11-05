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

@export var end_turn_button_sound:AudioStream = null

var controls:Array[bool] = []
var slots:Array[AbilitySlot] = []
var hovered_slot:AbilitySlot = null
var player:Player = null
var selected_ability:Ability = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_slot_pressed()

func set_player(new_player:Player) -> void:
	player = new_player
	ap_container.set_player(new_player)
	player.start_turn.connect(_on_turn_start)
	player.end_turn.connect(_on_turn_end)
	player.stat_handler.stats_changed.connect(_set_movement)

func _ready() -> void:
	set_process_input(false)
	_connect_signals()
	_add_slots()

func _add_slots() -> void:
	for abi_slot:AbilitySlot in ability_slot_container.get_children():
		slots.push_back(abi_slot)
		abi_slot.ability_hovered.connect(_set_hovered_slot)
		abi_slot.mouse_entered.connect(_on_container_mouse_entered)
		abi_slot.mouse_exited.connect(_on_container_mouse_exited)

func _connect_signals() -> void:
	GlobalSignals.combat_start.connect(show_bar)
	GlobalSignals.combat_end.connect(hide_bar)
	
	GlobalSignals.combat_start.connect(func(): info_container.visible = true)
	GlobalSignals.combat_end.connect(func(): info_container.visible = false)
	
	input_area.mouse_entered.connect(_on_container_mouse_entered)
	input_area.mouse_exited.connect(_on_container_mouse_exited)
	end_turn_button.mouse_entered.connect(_on_container_mouse_entered)
	end_turn_button.mouse_exited.connect(_on_container_mouse_exited)

func _set_movement() -> void:
	movement_label.text = str(player.stat_handler.resources[Stats.ResourceStat.CURRENT_MOVEMENT])

func _on_turn_start() -> void:
	color_rect.hide()
	button_container.show()
	
func _on_turn_end() -> void:
	color_rect.show()

func _set_hovered_slot(new_slot:AbilitySlot) -> void:
	hovered_slot = new_slot
	
func _clear_hovered_slot(new_slot:AbilitySlot) -> void:
	if hovered_slot == new_slot: hovered_slot = null

func _slot_pressed() -> void:
	if color_rect.visible: return
	
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
	controls.push_back(true)
	ability_targeter.input_ok = false
	
	#Dont try to move when mouse in bar
	GlobalSignals.current_level.tile_manager.shooting_ok = false
	set_process_input(true)

func _on_container_mouse_exited() -> void:
	controls.pop_back()
	if len(controls) != 0: return
	
	ability_targeter.input_ok = true
	GlobalSignals.current_level.tile_manager.shooting_ok = true
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


func _on_end_turn_button_pressed() -> void:
	player.end_turn.emit()
	button_container.hide()
	GlobalSignals.play_audio.emit(end_turn_button_sound, AudioManager.AUDIO_TYPE.UI)
