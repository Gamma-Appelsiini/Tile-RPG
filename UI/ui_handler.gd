extends Control
class_name UIHandler

@export var inventory: Inventory = null
@export var globe_ui: GlobeUI = null
@export var stat_window: StatWindow = null
@export var dialogue_window: DialogueWindow = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Character"):
		stat_window.visible = !stat_window.visible
	elif event.is_action_pressed("Bag"):
		inventory.visible = !inventory.visible

func set_player(player:Player) -> void:
	GlobalSignals.player = player
	inventory.set_player(player)
	dialogue_window.set_player(player)
	stat_window.set_game_character(player)
