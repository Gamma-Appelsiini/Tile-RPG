extends Node3D
class_name ConnectionArrow

@onready var cone_mesh: MeshInstance3D = $Cone
@onready var area_3d: Area3D = $Cone/Area3D

const ORANGE_OUTLINE_MATERIAL := preload("uid://b156brgpmobv")
const SKILL_TREE_HIGHLIGHT_MATERIAL := preload("uid://cffun3ui4av2t")

func _ready() -> void:
	area_3d.mouse_entered.connect(func(): cone_mesh.material_overlay = SKILL_TREE_HIGHLIGHT_MATERIAL)
	area_3d.mouse_exited.connect(func(): cone_mesh.material_overlay = null)

func enable_connection() -> void:
	if cone_mesh.visible: return
	
	cone_mesh.scale = Vector3(0.001,0.001,0.001)
	cone_mesh.show()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(cone_mesh, "scale", Vector3(0.3,0.2,0.3), 0.45)
	
func disable_connection() -> void:
	if !cone_mesh.visible: return
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(cone_mesh, "scale", Vector3(0.001,0.001,0.001), 0.35)
	
	await tween.finished
	cone_mesh.hide()
