extends RigidBody3D
class_name Fragment

signal dissolved

@export var lifetime:float = 3
@export var collision_shape:CollisionShape3D
@export var dissolve_shader:ShaderMaterial = null
@export var fragment_mesh:MeshInstance3D = null

const FRAGMENT_DISSOLVE_MATERIAL:ShaderMaterial = preload("res://Tile-RPG/Breakables/fragment_dissolve_material.tres")
const DISSOLVE_TIME:float = 0.5

var elapsed_time:float = 0

func _ready() -> void:
	self.visible = false
	set_process(false)
	freeze = true
	apply_shader()

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
	var tween:Tween = create_tween()
	tween.tween_property(fragment_mesh.material_override, "shader_parameter/dissolveSlider", 1, DISSOLVE_TIME)
	
	await tween.finished
	dissolved.emit()
	queue_free()

func apply_shader() -> void:
	dissolve_shader = FRAGMENT_DISSOLVE_MATERIAL.duplicate()
	var original_material:StandardMaterial3D = fragment_mesh.mesh.surface_get_material(0)
	
	dissolve_shader.set_shader_parameter("baseColorTexture", original_material.albedo_texture)
	dissolve_shader.set_shader_parameter("normalTexture", original_material.normal_texture)
	dissolve_shader.set_shader_parameter("heightTexture", original_material.heightmap_texture)
	
	if original_material.roughness_texture:
		dissolve_shader.set_shader_parameter("roughnessTexture", original_material.roughness_texture)
	else:
		dissolve_shader.set_shader_parameter("use_roughness_texture", false)
		dissolve_shader.set_shader_parameter("roughnessSlider", original_material.roughness)
	
	fragment_mesh.material_override = dissolve_shader
