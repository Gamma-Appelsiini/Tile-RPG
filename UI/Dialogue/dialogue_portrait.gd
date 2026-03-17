extends VBoxContainer
class_name DialoguePortrait

@export var name_label: Label = null
@export var picture_rect: TextureRect = null
@export var color_rect: ColorRect = null

func set_character(new_character:GameCharacter) -> void:
	name_label.text = new_character.display_name
	picture_rect.texture = new_character.picture
	
func set_active() -> void:
	color_rect.visible = false
	
func set_passive() -> void:
	color_rect.visible = true

func set_shopkeeper(new_shop:Shop) -> void:
	name_label.text = new_shop.shop_name
	picture_rect.texture = new_shop.shop_portrait
