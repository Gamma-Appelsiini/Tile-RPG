extends Node3D
class_name Indicator

@onready var indicator_mesh: MeshInstance3D = %IndicatorMesh

const _MESH_SIZE:Vector3 = Vector3(1,1,1)
const _SPIN_TIME:float = 1

func _move_indicator() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(indicator_mesh,"rotation",indicator_mesh.rotation +Vector3(0, PI, 0), _SPIN_TIME)
	
	await tween.finished
	if visible: _move_indicator()

func _scale_indicator(size:Vector3) -> void:
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
	
	if size == Vector3(0,0,0): tween.set_trans(Tween.TRANS_EXPO)
	else:
		self.scale = Vector3(0,0,0)
		tween.set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(self,"scale", size, 0.25)
	await tween.finished
	
func hide_indicator(instant:bool = false) -> void:
	if !instant: await _scale_indicator(Vector3(0,0,0))
	visible = false
	
func show_indicator() -> void:
	visible = true
	_scale_indicator(_MESH_SIZE)
	_move_indicator()
	
