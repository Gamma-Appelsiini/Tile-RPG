extends Node3D
class_name TouchInteractable

@export var area_3d: Area3D = null
@export var enter_cooldown:float = 1.0

var on_cooldown:bool = false

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_entered)
	
func _on_area_entered(_body:Node3D) -> void:
	if on_cooldown: return
	_start_cd_timer()
	_on_interaction()

func _start_cd_timer() -> void:
	if enter_cooldown == 0: return
	
	on_cooldown = true
	await get_tree().create_timer(enter_cooldown).timeout
	on_cooldown = false
	
#Override this
func _on_interaction() -> void:
	pass
