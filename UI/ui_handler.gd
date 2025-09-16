extends Control
class_name UIHandler

@export var character_window:StatWindow = null
@export var inventory: Inventory = null
@onready var globe_ui: GlobeUI = %GlobeUI
@export var stat_window: StatWindow = null
@export var dialogue_window: DialogueWindow = null

var input_enabled:bool = true

func _input(event: InputEvent) -> void:
	if !input_enabled: return
	if event.is_action_pressed("Character"):
		character_window.visible = !character_window.visible
	elif event.is_action_pressed("Bag"):
		inventory.visible = !inventory.visible

func set_player(player:Player) -> void:
	#await inventory.ready
	inventory.player = player
	await stat_window.ready
	await dialogue_window.ready
	
	
	dialogue_window.player = player
	stat_window.set_game_character(player)
