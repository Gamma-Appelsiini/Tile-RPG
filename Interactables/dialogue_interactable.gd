extends Interactable
class_name DialogueInteractable

@export var dialogue_resource:DialogueResource = null
@export var dialogue_name:String = "Default Name"
@export var dialogue_picture:Texture2D = null

const DBUBBLE_SCENE:PackedScene = preload("res://Tile-RPG/UI/Dialogue/dialogue_bubble.tscn")

var dialogue_bubble:DialogueBubble = null

func _ready() -> void:
	_on_creation()
	
	if get_parent() is GameCharacter:
		dialogue_resource.speaker = get_parent() as GameCharacter

func interact() -> void:
	dialogue_bubble = DBUBBLE_SCENE.instantiate()
	dialogue_bubble.dialogue_finished.connect(_on_dialogue_finished)
	add_child(dialogue_bubble)
	
	GlobalSignals.disable_player_movement.emit()
	interact_area.monitoring = false
	dialogue_bubble.set_params(dialogue_name,dialogue_picture, indicator_place, player.player_camera)
	dialogue_bubble.show_dialogue(dialogue_resource)

func _on_dialogue_finished() -> void:
	GlobalSignals.enable_player_movement.emit()
	if !dialogue_resource.repeatable:
		queue_free()
		return
		
	interact_area.monitoring = true
