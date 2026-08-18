extends Node3D
class_name EnviromentHandler

@export var north: Node = null
@export var east: Node = null
@export var south: Node = null
@export var west: Node = null
@onready var player_camera2: PlayerCamera = $PlayerCamera

const WALL_CUTOFF_MATERIAL := preload("uid://bdnyikm3cfm43")
const CUTOFF_HEIGHT:float = 0.25
const DEFAULT_HEIGHT:float = 3

@onready var wall_parents:Array[Node] = [north, east, south, west]
var north_shaders:Dictionary[StandardMaterial3D,ShaderMaterial] = {}
var east_shaders:Dictionary[StandardMaterial3D,ShaderMaterial] = {}
var south_shaders:Dictionary[StandardMaterial3D,ShaderMaterial] = {}
var west_shaders:Dictionary[StandardMaterial3D,ShaderMaterial] = {}
@onready var nodes_shaders:Dictionary[Node, Dictionary] = {north: north_shaders, east: east_shaders, south: south_shaders, west: west_shaders}
@onready var direction_shaders:Dictionary[PlayerCamera.CameraDirection, Dictionary] = {
	PlayerCamera.CameraDirection.NORTH: north_shaders,
	PlayerCamera.CameraDirection.EAST: east_shaders,
	PlayerCamera.CameraDirection.SOUTH: south_shaders,
	PlayerCamera.CameraDirection.WEST: west_shaders,
	}
var player_camera:PlayerCamera = null

func _ready() -> void:
	_create_shaders()
	_set_player_camera(player_camera2)

func _set_player_camera(new_player_camera:PlayerCamera) -> void:
	player_camera = new_player_camera
	player_camera.rotation_changed.connect(_rotation_changed)
	_animate_shaders(direction_shaders[PlayerCamera.CameraDirection.SOUTH].values(), CUTOFF_HEIGHT)

func _animate_shaders(shaders:Array[ShaderMaterial], height:float) -> void:
	for shader_material:ShaderMaterial in shaders:
		var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(shader_material, "shader_parameter/local_height", height, 0.4)

func _rotation_changed(to_show:Array, to_hide:Array) -> void:
	for direction:PlayerCamera.CameraDirection in to_hide:
		if !to_show.has(direction):
			_animate_shaders(direction_shaders[direction].values(), DEFAULT_HEIGHT)
		
	for direction:PlayerCamera.CameraDirection in to_show:
		_animate_shaders(direction_shaders[direction].values(), CUTOFF_HEIGHT)

func _create_shaders() -> void:
	for node_parent:Node in wall_parents:
		for mesh_child:MeshInstance3D in node_parent.get_children():
			for i:int in range(mesh_child.mesh.get_surface_count()):
				var mesh_material:StandardMaterial3D = mesh_child.get_active_material(i)
				if !nodes_shaders[node_parent].keys().has(mesh_material):
					var new_shader_material:ShaderMaterial = _create_new_wall_material(mesh_material)
					nodes_shaders[node_parent][mesh_material] = new_shader_material
					mesh_child.material_override = new_shader_material
				else: mesh_child.material_override = nodes_shaders[node_parent][mesh_material]
					

func _create_new_wall_material(wall_material:StandardMaterial3D) -> ShaderMaterial:
	var new_shader_material:ShaderMaterial = WALL_CUTOFF_MATERIAL.duplicate()
	new_shader_material.set_shader_parameter("local_height", DEFAULT_HEIGHT)
	
	new_shader_material.set_shader_parameter("albedo", wall_material.albedo_color)
	new_shader_material.set_shader_parameter("texture_albedo", wall_material.albedo_texture)

	new_shader_material.set_shader_parameter("metallic", wall_material.metallic)
	new_shader_material.set_shader_parameter("texture_metallic", wall_material.metallic_texture)
	
	new_shader_material.set_shader_parameter("roughness", wall_material.roughness)
	new_shader_material.set_shader_parameter("texture_roughness", wall_material.roughness_texture)

	if wall_material.normal_enabled:
		new_shader_material.set_shader_parameter("texture_normal", wall_material.normal_texture)
		new_shader_material.set_shader_parameter("normal_scale", wall_material.normal_scale)
	else:
		new_shader_material.set_shader_parameter("texture_normal", null)
		new_shader_material.set_shader_parameter("normal_scale", 1.0)

	if wall_material.emission_enabled:
		new_shader_material.set_shader_parameter("emission", wall_material.emission)
		new_shader_material.set_shader_parameter("emission_energy", wall_material.emission_energy_multiplier) 
		new_shader_material.set_shader_parameter("texture_emission", wall_material.emission_texture)
	else:
		new_shader_material.set_shader_parameter("emission", Color.BLACK)
		new_shader_material.set_shader_parameter("emission_energy", 0.0)
		new_shader_material.set_shader_parameter("texture_emission", null)
	
	return new_shader_material
