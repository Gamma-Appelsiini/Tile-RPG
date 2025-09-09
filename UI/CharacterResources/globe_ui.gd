extends Control
class_name GlobeUI

@export var hp_viewport_texture_rect: TextureRect = null
@export var spirit_viewport_texture_rect: TextureRect = null

func set_viewport_path(vp:SubViewport, text_rect:TextureRect = hp_viewport_texture_rect) -> void:
	text_rect.texture = vp.get_texture()
