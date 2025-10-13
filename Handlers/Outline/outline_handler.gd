extends Node
class_name OutlineHandler

enum OUTLINE_TYPE {ENEMY, FRIENDLY, NEUTRAL, OBJECT}

@export var mesh_to_outline:MeshInstance3D = null
@export var outline_type:OUTLINE_TYPE = OUTLINE_TYPE.OBJECT

const ENEMY_OUTLINE:ShaderMaterial = preload("uid://dqth8h8mfgfin")
const FRIENDLY_OUTLINE:ShaderMaterial = preload("uid://dixo86dkwapgy")
const NEUTRAL_OUTLINE:ShaderMaterial = preload("uid://uk4pc6755tq1")
const OBJECT_OUTLINE:ShaderMaterial = preload("uid://l0c1ypupcv43")
const OUTLINES:Dictionary[OUTLINE_TYPE, ShaderMaterial] = {
	OUTLINE_TYPE.ENEMY: ENEMY_OUTLINE,
	OUTLINE_TYPE.FRIENDLY: FRIENDLY_OUTLINE,
	OUTLINE_TYPE.NEUTRAL: NEUTRAL_OUTLINE,
	OUTLINE_TYPE.OBJECT: OBJECT_OUTLINE,}

func _ready() -> void:
	GlobalSignals.show_outline.connect(_show_outline)
	GlobalSignals.hide_outline.connect(_hide_outline)
	
func _show_specific_outline(target:Node3D) -> void:
	if get_parent() == target:
		_show_outline()
		
func _hide_specific_outline(target:Node3D) -> void:
	if get_parent() == target:
		_hide_outline()
	
func _show_outline() -> void:
	var outline_material:ShaderMaterial = OUTLINES[outline_type]
	
	var surface_count:int = mesh_to_outline.mesh.get_surface_count()
	for i in surface_count:
		var mat := mesh_to_outline.mesh.surface_get_material(i)
		if mat != null: mat.next_pass = outline_material

func _hide_outline() -> void:
	var surface_count:int = mesh_to_outline.mesh.get_surface_count()
	for i in surface_count:
		var mat := mesh_to_outline.mesh.surface_get_material(i)
		if mat != null: mat.next_pass = null
