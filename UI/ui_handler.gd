extends Control
class_name UIHandler

@export var inventory: Inventory = null
@export var globe_ui: GlobeUI = null
@export var stat_window: StatWindow = null
@export var dialogue_window: DialogueWindow = null
@export var ability_bar: AbilityBar = null
@export var abilities_container: AbilitiesContainer = null
@export var ability_targeter: AbilityTargeter = null
@export var combat_ui: CombatUI = null
@export var menu_buttons: MenuButtonsPanel = null
@export var shop_window: ShopWindow = null
@export var main_menu: MainMenu = null


const DAMAGE_NUMBER_SCENE:PackedScene = preload("uid://dac2s2r20qif4")

var in_combat:bool = false

func _ready() -> void:
	GlobalSignals.show_damage_number.connect(show_damage_number)
	GlobalSignals.show_miss_text.connect(show_miss_text)
	GlobalSignals.combat_start.connect(func(): in_combat = true)
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	GlobalSignals.show_floating_text.connect(show_text_at_pos)
	
	_connect_menu_buttons()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Character"):
		_toggle_character()
	elif event.is_action_pressed("Bag"):
		toggle_inv()
	elif event.is_action_pressed("Abilities"):
		_toggle_abilities()
	elif event.is_action_pressed("Esc"):
		_handle_esc()

func _handle_esc() -> void:
	if stat_window.visible or inventory.visible or shop_window.visible or abilities_container.visible:
		stat_window.hide()
		inventory.hide()
		shop_window.hide()
		abilities_container.hide_container()
	else: _toggle_menu()
		

func _toggle_menu() -> void:
	stat_window.hide()
	inventory.hide()
	shop_window.hide()
	abilities_container.hide_container()
	
	if main_menu.settings_panel.visible: main_menu.settings_panel.hide()
	else: main_menu.visible = !main_menu.visible

func _toggle_character() -> void:
	if main_menu.visible: return
	stat_window.visible = !stat_window.visible

func toggle_inv() -> void:
	if main_menu.visible: return
	inventory.visible = !inventory.visible
	
	if shop_window.visible and !inventory.visible:
		shop_window.hide()

func _toggle_abilities() -> void:
	if main_menu.visible: return
	if in_combat: return
	if !abilities_container.visible: abilities_container.show_container()
	else: abilities_container.hide_container()

func _connect_menu_buttons() -> void:
	#TODO
	menu_buttons.open_abi.connect(_toggle_abilities)
	menu_buttons.open_inv.connect(toggle_inv)
	menu_buttons.open_char.connect(_toggle_character)
	menu_buttons.open_settings.connect(_toggle_menu)

func set_player(player:Player) -> void:
	ability_bar.set_player(player)
	inventory.set_player(player)
	dialogue_window.set_player(player)
	stat_window.set_game_character(player)
	abilities_container.set_player(player)

func load_from_data(save_data:Dictionary) -> void:
	GlobalSignals.ui_handler = self
	inventory.load_inv_from_data(save_data)
	
	abilities_container.load_from_data(save_data)
	
	var ability_bar_array:Array = save_data["ability_bar"]
	ability_bar.load_from_array(ability_bar_array)

func save_to_data(save_data:Dictionary) -> void:
	inventory.save_inv_to_data(save_data)
	abilities_container.save_to_data(save_data)
	save_data["ability_bar"] = ability_bar.save_to_data()

func show_damage_number(amount:int, target_node:Node3D, crit:bool = false) -> void:
	var new_number:DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	add_child(new_number)
	new_number.spawn_at_node(amount,target_node, crit)

func show_miss_text(miss_text:String, target_node:Node3D) -> void:
	var new_number:DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	add_child(new_number)
	new_number.spawn_text_at_node(miss_text, target_node)
	
func show_text_at_pos(miss_text:String, target_node:Node3D, font_color:Color) -> void:
	var new_number:DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	add_child(new_number)
	new_number.spawn_text_at_node(miss_text, target_node, font_color)
