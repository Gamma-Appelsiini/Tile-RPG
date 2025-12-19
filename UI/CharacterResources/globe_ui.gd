extends Control
class_name GlobeUI

@export var hp_panel: GlobePanel = null
@export var spirit_panel: GlobePanel = null

func set_viewport_path(vp:SubViewport, globe_panel:GlobePanel = hp_panel) -> void:
	globe_panel.viewport_rect.texture = vp.get_texture()
