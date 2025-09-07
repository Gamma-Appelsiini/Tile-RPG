extends Node3D
class_name Breakable

@export_flags_3d_physics var fragment_collision_layer:int = 1
@export_flags_3d_physics var fragment_collision_mask:int = 1
@export var explosion_speed:float = 6
@export var min_frag_lifetime:float = 1.2
@export var max_frag_lifetime:float = 1.8
@export var hit_area: Area3D
@export var static_body:StaticBody3D
@export var break_sound: AudioStream = null
@export var original_model:MeshInstance3D = null
@export var fragments_node:Node3D = null
@export var pieces_node:Node3D = null

var audio_player_3d: AudioStreamPlayer3D = null
var explode_origin:Vector3 = Vector3.ZERO

func _ready() -> void:
	hit_area.connect("body_entered", Callable(self, "_on_Area3D_body_entered"))
	
	audio_player_3d = AudioStreamPlayer3D.new()
	add_child(audio_player_3d)
	audio_player_3d.stream = break_sound

#TODO change to be destroyed by hitting with weapon
func _on_Area3D_body_entered(body: Node) -> void:
	if body is Player:
		explode_origin = body.global_position
		_explode()

func _explode() -> void:
	hit_area.set_deferred("monitoring", false)
	original_model.visible = false
	static_body.queue_free()
	
	var last_frag:Fragment = fragments_node.get_children().back()
	last_frag.dissolved.connect(queue_free)
	_play_sound()
	
	for frag:Fragment in fragments_node.get_children():
		var fragment_speed:float = randf_range(explosion_speed-1,explosion_speed+1)
		var vel:Vector3 = (frag.global_transform.origin - explode_origin) * fragment_speed
		frag.explode(vel)
	
func _play_sound() -> void:
	audio_player_3d.global_position = explode_origin
	audio_player_3d.play()
