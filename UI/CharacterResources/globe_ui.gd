extends Control
class_name GlobeUI

@export var viewport_texture_rect: TextureRect = null

var viewport_texture:ViewportTexture = null

func set_viewport_path(vp:SubViewport) -> void:
	viewport_texture = ViewportTexture.new()
	viewport_texture.viewport_path = vp.get_path()
	viewport_texture_rect.texture = vp.get_texture()
