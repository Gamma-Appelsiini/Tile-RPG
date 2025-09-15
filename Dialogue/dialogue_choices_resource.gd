extends Resource
class_name DialogueChoicesResource

@export_multiline var choices:Array[String] = []
@export var choices_signals:Array[String] = []
@export var next_dialogues:Array[DialogueResource] = []

@export var checks:Array[StatCheck] = []
