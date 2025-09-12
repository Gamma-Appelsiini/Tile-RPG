extends Resource
class_name DialogueResource

signal last_text

@export_multiline var dialogues:Array[String] = []
@export_multiline var choices:Array[String] = []
@export var checks:Array[StatCheck] = []
@export var next_dialogue:DialogueResource = null
@export var repeatable:bool = false

var current_spot:int = 0
var speaker:GameCharacter = null

func get_next_dialogue() -> String:
	if current_spot >= len(dialogues):
		_end_of_dialogue()
		return ""
	elif current_spot == len(dialogues) - 1:
		last_text.emit()
	
	var next_dialogue_string:String = dialogues[current_spot]
	current_spot += 1
	
	return next_dialogue_string

func _end_of_dialogue() -> void:
	if repeatable:
		current_spot = 0
