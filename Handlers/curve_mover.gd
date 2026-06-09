extends Node
class_name CurveMover

signal target_reached

@export var speed: float = 10.0
@export var curve_amount: float = 3.0
@export var lateral_spread: float = 2.0
@export_exp_easing var acceleration_easing: float = -2.0

var to_move: Node3D = null
var _target: Node3D = null

var _bezier_t: float = 0.0
var _bezier_start: Vector3
var _bezier_control: Vector3
var _calculated_duration: float = 1.0

func _init() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if not is_instance_valid(to_move) or not is_instance_valid(_target):
		set_process(false)
		return
		
	_move_with_curve(delta)

func _move_with_curve(delta: float) -> void:
	_bezier_t += delta / _calculated_duration
	var t = clampf(_bezier_t, 0.0, 1.0)
	var eased_t = ease(t, acceleration_easing)
	var current_end := _target.global_position + Vector3(0, 1.5, 0)

	to_move.global_position = _quadratic_bezier(_bezier_start, _bezier_control, current_end, eased_t)

	if t >= 1.0:
		set_process(false)
		target_reached.emit()

func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	return (1.0 - t) * (1.0 - t) * p0 + 2.0 * (1.0 - t) * t * p1 + t * t * p2

func _calculate_duration(initial_end:Vector3) -> void:
	var distance: float = _bezier_start.distance_to(initial_end)
	_calculated_duration = distance / speed

	if _calculated_duration <= 0.001:
		_calculated_duration = 0.001

func move_to_target(node_to_move: Node3D, target: Node3D) -> void:
	to_move = node_to_move
	_target = target
	
	if to_move is RigidBody3D:
		to_move.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		to_move.freeze = true
	
	_bezier_t = 0.0
	_bezier_start = to_move.global_position
	
	var initial_end := _target.global_position + Vector3(0, 1.5, 0)
	var midpoint := (_bezier_start + initial_end) / 2.0
	_calculate_duration(initial_end)

	var random_offset = Vector3(
		randf_range(-lateral_spread, lateral_spread),
		curve_amount,
		randf_range(-lateral_spread, lateral_spread)
	)
	_bezier_control = midpoint + random_offset
	
	#Prevent the control point from dipping below the starting height
	if _bezier_control.y < _bezier_start.y:
		_bezier_control.y = _bezier_start.y
	
	set_process(true)
