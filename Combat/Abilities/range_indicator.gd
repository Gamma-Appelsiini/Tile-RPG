extends Node3D
class_name RangeIndicator

@export var tile_mesh: MeshInstance3D = null

const RANGE_INDICATOR_MATERIAL:ShaderMaterial = preload("uid://bnioc7r0i0qjx")
const RANGE_INDICATOR_ENEMY_MATERIAL:ShaderMaterial = preload("uid://b3kh0f8nymfnf")

func _ready() -> void:
	self.visibility_changed.connect(_reset_color)
	
func _reset_color() -> void:
	if self.visible == false:
		tile_mesh.material_override = RANGE_INDICATOR_MATERIAL
		
func set_enemy_color() -> void:
	tile_mesh.material_override = RANGE_INDICATOR_ENEMY_MATERIAL
