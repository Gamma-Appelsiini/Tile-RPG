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

const DAMAGE_NUMBER_SCENE:PackedScene = preload("uid://dac2s2r20qif4")

var in_combat:bool = false

func _ready() -> void:
	GlobalSignals.show_damage_number.connect(show_damage_number)
	GlobalSignals.show_miss_text.connect(show_miss_text)
	GlobalSignals.combat_start.connect(func(): in_combat = true)
	GlobalSignals.combat_end.connect(func(): in_combat = false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Character"):
		stat_window.visible = !stat_window.visible
	elif event.is_action_pressed("Bag"):
		inventory.visible = !inventory.visible
	elif event.is_action_pressed("Abilities"):
		if in_combat: return
		if !abilities_container.visible: abilities_container.show_container()
		else: abilities_container.hide_container()

func set_player(player:Player) -> void:
	GlobalSignals.player = player
	ability_bar.set_player(player)
	inventory.set_player(player)
	dialogue_window.set_player(player)
	stat_window.set_game_character(player)
	abilities_container.set_player(player)

func load_from_data(save_data:Dictionary) -> void:
	await inventory.ready
	inventory.load_inv_from_data(save_data)
	
	abilities_container.load_from_data(save_data)
	
	var ability_bar_array:Array[String] = save_data["ability_bar"]
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
