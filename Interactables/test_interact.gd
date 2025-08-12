extends Interactable
class_name TestInteractable

@export var change_to_level_id:String = ""
@export var came_from_string:String = ""

func interact() -> void:
	player.came_from_id = came_from_string
	GlobalSignals.change_level.emit(change_to_level_id)
