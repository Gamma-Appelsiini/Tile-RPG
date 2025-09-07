extends RigidBody3D
class_name Fragment

signal dissolved

@export var lifetime:float = 2
@export var collision_shape:CollisionShape3D

const FRAGMENT_DISSOLVE_MATERIAL:ShaderMaterial = preload("res://Tile-RPG/Breakables/fragment_dissolve_material.tres")
const DISSOLVE_TIME:float = 0.5

@export var dissolve_shader:ShaderMaterial = null
var elapsed_time:float = 0
@export var fragment_mesh:MeshInstance3D = null

func _ready() -> void:
	self.visible = false
	set_process(false)
	freeze = true

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > lifetime: _dissolve()

func explode(vel:Vector3) -> void:
	self.visible = true
	set_process(true)
	freeze = false
	linear_velocity = vel

func _dissolve() -> void:
	set_process(false)
	
	dissolve_shader.resource_local_to_scene = true
	dissolve_shader = dissolve_shader.duplicate()
	fragment_mesh.material_override = dissolve_shader
	
	var tween:Tween = create_tween()
	tween.tween_property(fragment_mesh.material_override, "shader_parameter/dissolveSlider", 1, DISSOLVE_TIME)
	
	await tween.finished
	dissolved.emit()
	queue_free()

func apply_shader() -> void:
	dissolve_shader = FRAGMENT_DISSOLVE_MATERIAL.duplicate()
	dissolve_shader.set_shader_parameter("baseColorTexture", fragment_mesh.mesh.surface_get_material(0).albedo_texture)
	fragment_mesh.material_override = dissolve_shader
