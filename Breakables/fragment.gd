extends RigidBody3D
class_name Fragment

signal dissolved

@export var lifetime:float = 2
@export var collision_shape:CollisionShape3D

const DISSOLVE_TIME:float = 0.5
var elapsed_time:float = 0

func _init() -> void:
	self.visible = false
	set_process(false)
	freeze = true

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > lifetime: _dissolve()

func explode(vel:Vector3) -> void:
	self.visible = true
	set_process(true)
	freeze = false
	linear_velocity = vel

func _dissolve() -> void:
	dissolved.emit()
	queue_free()

func init_from_mesh(source:MeshInstance3D):
	global_transform = source.global_transform
	var mesh_inst:MeshInstance3D = source.duplicate()
	mesh_inst.transform = Transform3D.IDENTITY
	add_child(mesh_inst)
	
	collision_shape.shape = source.mesh.create_convex_shape()
