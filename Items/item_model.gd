extends RigidBody3D
class_name ItemModel

#Don't rename default collision shape name
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var item_mesh:MeshInstance3D

var end_scale:Vector3 = Vector3.ZERO

func _ready() -> void:
	collision_shape_3d.set_deferred("disabled", true)
	self.visible = false
	freeze = true

func appear() -> void:
	collision_shape_3d.set_deferred("disabled", false)
	freeze = false
	end_scale =  item_mesh.scale
	item_mesh.scale = Vector3(0.001,0.001,0.001)
	self.visible = true
	
	var tween:Tween = create_tween()
	tween.tween_property(item_mesh,"scale", end_scale, 0.35).set_ease(Tween.EASE_OUT)
