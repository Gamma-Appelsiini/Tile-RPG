extends Control
class_name UIHandler

@export var inventory: Inventory = null
@export var globe_ui: GlobeUI = null
@export var stat_window: StatWindow = null
@export var dialogue_window: DialogueWindow = null
@export var ability_bar: AbilityBar = null
@export var abilities_container: AbilitiesContainer = null
@export var combat_ui: CombatUI = null
@export var menu_buttons: MenuButtonsPanel = null
@export var shop_window: ShopWindow = null
@export var main_menu: MainMenu = null
@export var loading_screen: LoadingScreen = null
@export var start_menu: StartMenu = null
@export var loot_window: LootWindow = null
@export var crafting_window: CraftingWindow = null

const DAMAGE_NUMBER_SCENE:PackedScene = preload("uid://dac2s2r20qif4")
const DAMAGE_NUMBER = preload("uid://dac2s2r20qif4")

var in_combat:bool = false
var dmg_numbers:Array[DamageNumber] = []

func _ready() -> void:
	GlobalSignals.show_damage_number.connect(show_damage_number)
	GlobalSignals.show_miss_text.connect(show_miss_text)
	GlobalSignals.combat_start.connect(func(): in_combat = true)
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	GlobalSignals.show_floating_text.connect(show_text_at_pos)
	
	_connect_menu_buttons()
	_generate_dmg_numbers()

func _generate_dmg_numbers() -> void:
	while dmg_numbers.size() < 10:
		var new_number:DamageNumber = DAMAGE_NUMBER.instantiate()
		add_child(new_number)
		dmg_numbers.push_back(new_number)

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
	if main_menu.visible: _toggle_menu()
	elif stat_window.visible or inventory.visible or shop_window.visible or abilities_container.visible or loot_window.visible or crafting_window.visible:
		if crafting_window.visible: crafting_window._close_crafting()
		stat_window.hide()
		inventory.hide()
		shop_window.hide()
		abilities_container.hide_container()
		loot_window.hide()
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
	if abilities_container.visible and inventory.visible: abilities_container.hide()
	if shop_window.visible and !inventory.visible:
		shop_window.hide()

func _toggle_abilities() -> void:
	if main_menu.visible or shop_window.visible: return
	if in_combat: return

	if !abilities_container.visible:
		inventory.hide()
		stat_window.hide()
		abilities_container.show_container()
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
	inventory.load_inv_from_data(save_data)
	
	abilities_container.load_from_data(save_data)
	
	var ability_bar_array:Array = save_data["ability_bar"]
	ability_bar.load_from_array(ability_bar_array)

func save_to_data(save_data:Dictionary) -> void:
	inventory.save_inv_to_data(save_data)
	abilities_container.save_to_data(save_data)
	save_data["ability_bar"] = ability_bar.save_to_data()

func show_damage_number(amount:int, target_node:Node3D, crit:bool = false) -> void:
	var free_dmg_number:DamageNumber = _get_free_dmg_number()
	free_dmg_number.spawn_at_node(amount,target_node, crit)

func _get_free_dmg_number() -> DamageNumber:
	var free_dmg_number:DamageNumber = null
	for i:int in len(dmg_numbers):
		if dmg_numbers[i].free_to_use: free_dmg_number = dmg_numbers[i]
		
	if free_dmg_number == null:
		dmg_numbers.push_back(DAMAGE_NUMBER.instantiate())
		free_dmg_number = dmg_numbers.back()
		add_child(free_dmg_number)
	
	return free_dmg_number

func show_miss_text(miss_text:String, target_node:Node3D) -> void:
	const MISS_COLOR:Color = Color(0.222, 0.211, 1.0, 1.0)
	var free_dmg_number:DamageNumber = _get_free_dmg_number()
	free_dmg_number.spawn_text_at_node(miss_text, target_node, MISS_COLOR)
	
func show_text_at_pos(miss_text:String, target_node:Node3D, font_color:Color) -> void:
	var free_dmg_number:DamageNumber = _get_free_dmg_number()
	free_dmg_number.spawn_text_at_node(miss_text, target_node, font_color)
