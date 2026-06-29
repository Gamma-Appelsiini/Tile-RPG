extends Node3D
class_name FollowCamera

@export var follow_x:bool = false
@export var follow_y:bool = false
@export var follow_z:bool = false
@onready var camera_3d: Camera3D = $Camera3D

func _process(_delta: float) -> void:
	if follow_x: global_position.x = GlobalSignals.player.global_position.x
	if follow_y: global_position.y = GlobalSignals.player.global_position.y
	if follow_z: global_position.z = GlobalSignals.player.global_position.z
