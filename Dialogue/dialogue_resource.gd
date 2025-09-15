extends Resource
class_name DialogueResource

signal last_text
signal dialogue_turn(speaker:SPEAKER)

enum SPEAKER {PLAYER, DIALOGUE_OWNER}

@export_multiline var dialogues:Array[String] = []
@export var dialogue_turns:Array[SPEAKER] = []
@export var next_dialogue:DialogueResource = null
@export var complete_signal:String = ""
@export var choices_resource:DialogueChoicesResource = null
@export var repeatable:bool = false

var current_spot:int = 0
var speaker:GameCharacter = null
var whos_turn:SPEAKER = SPEAKER.PLAYER

func get_next_dialogue() -> String:
	if current_spot >= len(dialogues):
		_end_of_dialogue()
		return ""
	elif current_spot == len(dialogues) - 1:
		last_text.emit()
	
	var next_dialogue_string:String = dialogues[current_spot]
	current_spot += 1
	
	var whos_speaking:SPEAKER = dialogue_turns[current_spot]
	dialogue_turn.emit(whos_speaking)
	
	whos_turn = dialogue_turns[current_spot]
	
	return next_dialogue_string

func get_whos_turn() -> SPEAKER:
	return whos_turn

func _end_of_dialogue() -> void:
	if repeatable:
		current_spot = 0
