extends Node3D
class_name Indicator

@onready var indicator_mesh: MeshInstance3D = %IndicatorMesh

var _spin_time:float = 1
const _MESH_SIZE:Vector3 = Vector3(0.6,0.8,0.8)

func _move_indicator() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(indicator_mesh,"rotation",indicator_mesh.rotation +Vector3(0, PI, 0), _spin_time)
	
	await tween.finished
	if visible: _move_indicator()

func _scale_indicator(size:Vector3) -> Tween: 
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(indicator_mesh,"scale", size, 0.2)
	return tween
	
func hide_indicator(instant:bool = false) -> void:
	if !instant:
		var tween:Tween = _scale_indicator(Vector3(0,0,0))
		await tween.finished
	visible = false
	
func show_indicator() -> void:
	visible = true
	_scale_indicator(_MESH_SIZE)
	_move_indicator()
	
