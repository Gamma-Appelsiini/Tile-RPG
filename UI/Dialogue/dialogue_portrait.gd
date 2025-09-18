extends VBoxContainer
class_name DialoguePortrait

@onready var name_label: Label = %NameLabel
@onready var picture_rect: TextureRect = %PictureRect
@onready var color_rect: ColorRect = %ColorRect

func set_character(new_character:GameCharacter) -> void:
	name_label.text = new_character.display_name
	picture_rect.texture = new_character.picture
	
func set_active() -> void:
	color_rect.visible = false
	
func set_passive() -> void:
	color_rect.visible = true
