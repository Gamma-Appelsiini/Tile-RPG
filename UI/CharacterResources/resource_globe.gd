extends Node3D
class_name ResourceGlobe

@onready var liquid_mesh: MeshInstance3D = %LiquidMesh
@onready var sub_viewport: SubViewport = %SubViewport
@onready var camera_pos: Node3D = %CameraPos
@onready var camera_3d: Camera3D = %Camera3D

const MAX_AMOUNT:float = 1.5
const MIN_AMOUNT:float = -0.5

var liquid_material:ShaderMaterial = preload("res://Tile-RPG/UI/CharacterResources/hp_material.tres").duplicate()

func _ready() -> void:
	liquid_mesh.set_surface_override_material(0,liquid_material)

func _process(_delta: float) -> void:
	camera_3d.global_position = camera_pos.global_position

func set_amount(liquid_amount:float) -> void:
	liquid_amount = clamp(liquid_amount,0.0,1.0)
	var amount:float = (MAX_AMOUNT+abs(MIN_AMOUNT)) * liquid_amount
	
	liquid_material.set_shader_parameter("liquid_amount", MIN_AMOUNT + amount)

func get_viewport_path() -> SubViewport:
	return sub_viewport
