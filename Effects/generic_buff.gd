extends Effect
class_name GenericBuff

@export var balls: CPUParticles3D = null
@export var aura_mesh: MeshInstance3D = null

const LIFE_TIME:float = 1.4

var start_color:Color
var end_color:Color

func set_color(new_color:Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	balls.mesh.material.albedo_color = new_color
	
	end_color = new_color
	start_color = new_color
	start_color.a = 0
	var shader_material:ShaderMaterial = aura_mesh.material_override
	shader_material.set_shader_parameter("ColorParameter", start_color)

func animate_aura_color() -> void:
	var shader_material:ShaderMaterial = aura_mesh.material_override
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(shader_material, "shader_parameter/ColorParameter", end_color, LIFE_TIME / 2)
	
	await tween.finished
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(shader_material, "shader_parameter/ColorParameter", start_color, LIFE_TIME / 2)
