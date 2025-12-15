extends Control
class_name CharacterInfoBar

@onready var status_container: HBoxContainer = $StatusContainer

const STATUS_PANEL := preload("uid://ckjtakb74tlm2")

var game_char:GameCharacter = null

func set_game_character(new_gc:GameCharacter):
	game_char = new_gc
	game_char.status_handler.status_added.connect(_add_status)

func _add_status(new_status:Status):
	new_status.remove_status.connect(_remove_status.bind(new_status))
	var new_spanel:StatusPanel = STATUS_PANEL.instantiate()
	status_container.add_child(new_spanel)
	new_spanel.set_status(new_status)
	
func _remove_status(status:Status):
	status_container.remove_child(status)
