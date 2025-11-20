extends Node
class_name Status

signal remove_status
signal duration_changed

enum STATUS_TYPE {BUFF, DEBUFF}

@export var status_name:String = "Default Name"
@export var status_type:STATUS_TYPE = STATUS_TYPE.BUFF
@export var unique:bool = false
@export var remove_after_combat:bool = true
@export var max_duration:int = 0
@export var picture:Texture2D = null
@export_multiline var description:String = "Default description"

var current_duration:int = 0
var affected_gchar:GameCharacter = null
var status_creator:GameCharacter = null
var affixes:Array[Affix] = []

func connect_status(new_char:GameCharacter) -> void:
	current_duration = max_duration
	affected_gchar = new_char
	
	GlobalSignals.combat_manager.round_changed.connect(_on_round_change)
	if remove_after_combat: GlobalSignals.combat_end.connect(func(): remove_status.emit())
	
	_connet_to_char_signals()
	
func _on_round_change(_round_count:int) -> void:
	current_duration -= 1
	duration_changed.emit()
	if current_duration <= 0: remove_status.emit()

#Override this
func _connet_to_char_signals() -> void:
	pass
