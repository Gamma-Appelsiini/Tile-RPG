extends Control
class_name DialogueWindow

@onready var character_rect: TextureRect = %CharacterRect
@onready var npc_rect: TextureRect = %NpcRect
@onready var dialogue_panel: DialoguePanel = %DialoguePanel

var dialogue_resource:DialogueResource = null

func start_dialogue(new_dialogue:DialogueResource) -> void:
	dialogue_resource = new_dialogue

func set_pics(char_pic:Texture2D, npc_pic:Texture2D) -> void:
	character_rect.texture = char_pic
	npc_rect.texture = npc_pic
