extends Control
class_name DialogueWindow

@onready var character_rect: TextureRect = %CharacterRect
@onready var npc_rect: TextureRect = %NpcRect
@onready var dialogue_panel: DialoguePanel = %DialoguePanel

var dialogue_resource:DialogueResource = null
var player:Player = null
var last_dialogue_line:bool = false

func _ready() -> void:
	dialogue_panel.check_attempted.connect(_check_attempted)
	set_process_input(false)
	dialogue_resource.last_text.connect(_set_last)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") or event.is_action_pressed("Jump"):
		_proceed_dialogue()

func _set_last() -> void:
	last_dialogue_line = true

func _proceed_dialogue() -> void:
	if !last_dialogue_line:
		var text:String = dialogue_resource.get_next_dialogue()
		dialogue_panel.set_text(text,dialogue_resource.speaker.display_name)
		return
		
func _set_options() -> void:
	pass

func _hide_window() -> void:
	dialogue_resource = null
	self.visible = false

func start_dialogue(new_dialogue:DialogueResource) -> void:
	if new_dialogue == null: _hide_window

	dialogue_resource = new_dialogue
	var speaker_pic:Texture2D = null
	if dialogue_resource.speaker: speaker_pic = dialogue_resource.speaker.picture
	set_pics(player.picture, speaker_pic)
	self.visible = true
	
	var text:String = new_dialogue.get_next_dialogue()
	dialogue_panel.set_text(text)
	set_process_input(true)

func set_pics(char_pic:Texture2D, npc_pic:Texture2D) -> void:
	character_rect.texture = char_pic
	character_rect.visible = false
	npc_rect.texture = npc_pic
	npc_rect.visible = true

func _check_attempted(new_check:StatCheck) -> void:
	var passed_check:bool = new_check.attempt_check(player.stat_handler.main_stats[new_check.stat_type])
	
	if passed_check:
		if new_check.pass_func: new_check.pass_func.call()
		start_dialogue(new_check.pass_dialogue)
	else:
		if new_check.fail_func: new_check.fail_func.call()
		start_dialogue(new_check.fail_dialogue)
