extends Interactable
class_name CharacterDialogueInteractable

@export var dialogue_resource:DialogueResource

func _ready() -> void:
	_on_creation()
	if get_parent() is GameCharacter:
		dialogue_resource.speaker = get_parent() as GameCharacter

func interact() -> void:
	GlobalSignals.start_dialogue.emit(dialogue_resource)
	GlobalSignals.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished() -> void:
	interact_complete.emit()

	GlobalSignals.dialogue_finished.disconnect(_on_dialogue_finished)
	if !dialogue_resource.repeatable: return

func set_new_d_resource(new_resource:DialogueResource) -> void:
	dialogue_resource = new_resource
	interact_area.monitoring = true
