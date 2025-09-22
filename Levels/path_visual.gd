extends Node3D
class_name PathVisual

enum VISUAL {ARROW, CORNER, STRAIGTH}

@export var arrow: MeshInstance3D = null
@export var corner: MeshInstance3D = null
@export var straigth: MeshInstance3D = null
@export var rotation_parent: Node3D = null

func hide_visual() -> void:
	set_visual_rotation(0)
	self.visible = false
	arrow.visible = false
	corner.visible = false
	straigth.visible = false

func show_visual(type:VISUAL) -> void:
	self.visible = true
	
	if type == VISUAL.ARROW: arrow.visible = true
	elif type == VISUAL.CORNER: corner.visible = true
	else: straigth.visible = true

func set_visual_rotation(amount:float) -> void:
	rotation_parent.rotation.y = amount
