extends Node3D
class_name ResourceGlobe

enum LiquidType {HP, SPIRIT}

@export var liquid_mesh: MeshInstance3D = null
@export var sub_viewport: SubViewport = null
@export var camera_3d: Camera3D = null
@export var glass_ball: MeshInstance3D = null
@export var liquid_type:LiquidType = LiquidType.HP

const MAX_AMOUNT:float = 1.5
const MIN_AMOUNT:float = -0.5
const HP_MATERIAL:ShaderMaterial = preload("uid://qwh5idv3iyrm")
const SPIRIT_MATERIAL = preload("uid://cuukqo8bdq4jh")
const GLOBE_HP_GLASS_MATERIAL = preload("uid://cqdi0kdmoffy2")
const GLOBE_SPIRIT_GLASS_MATERIAL = preload("uid://c21kp4ucv22al")

var liquid_material:ShaderMaterial = null
@onready var node_3d: Node3D = $Node3D/Node3D

func _ready() -> void:
	if liquid_type == LiquidType.HP:
		liquid_material = HP_MATERIAL.duplicate()
		glass_ball.material_override = GLOBE_HP_GLASS_MATERIAL
	elif liquid_type == LiquidType.SPIRIT:
		liquid_material = SPIRIT_MATERIAL.duplicate()
		glass_ball.material_override = GLOBE_SPIRIT_GLASS_MATERIAL
	
	liquid_mesh.set_surface_override_material(0,liquid_material)

func _process(_delta: float) -> void:
	camera_3d.global_transform = node_3d.global_transform

func resource_changed(sh:StatHandler, stat_type:LiquidType) -> void:
	var current_amount:int = 0
	var max_amount:int = 0
	
	if stat_type == LiquidType.HP:
		current_amount = sh.resources[Stats.ResourceStat.CURRENT_HP]
		max_amount = sh.resources[Stats.ResourceStat.MAX_HP]
	elif stat_type == LiquidType.SPIRIT:
		current_amount = sh.resources[Stats.ResourceStat.CURRENT_SPIRIT]
		max_amount = sh.resources[Stats.ResourceStat.MAX_SPIRIT]
		
	_set_amount(float(current_amount) / float(max_amount))

func _set_amount(liquid_amount:float) -> void:
	liquid_amount = clamp(liquid_amount,0.0,1.0)
	var amount:float = (MAX_AMOUNT+abs(MIN_AMOUNT)) * liquid_amount
	
	var tween_time:float = abs(liquid_material.get_shader_parameter("liquid_amount")/2 - liquid_amount) * 2
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(liquid_material, "shader_parameter/liquid_amount", MIN_AMOUNT + amount, tween_time)

func get_viewport_path() -> SubViewport:
	return sub_viewport
