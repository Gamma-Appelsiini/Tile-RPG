extends Node3D
class_name GroundIndicator

const OK_COLOR:Color = Color(0.21, 0.7, 0.251, 1.0)
const BAD_COLOR:Color = Color(0.836, 0.0, 0.148, 1.0)
const GROUND_INDICATOR_MATERIAL = preload("uid://c58tnu5ctvy7b")

func set_indicator_color(valid_point:bool) -> void:
	if valid_point: GROUND_INDICATOR_MATERIAL.set_shader_parameter("base_color", OK_COLOR)
	else: GROUND_INDICATOR_MATERIAL.set_shader_parameter("base_color", BAD_COLOR)
