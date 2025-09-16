extends Interactable
class_name CharacterDialogueInteractable

@export var dialogue_resource:DialogueResource

func _ready() -> void:
	_on_creation()
	if get_parent() is GameCharacter:
		dialogue_resource.speaker = get_parent() as GameCharacter

func interact() -> void:
	interact_area.monitoring = false
	GlobalSignals.start_dialogue.emit(dialogue_resource)
