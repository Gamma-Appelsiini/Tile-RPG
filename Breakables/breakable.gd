extends Node3D
class_name Breakable

@export_flags_3d_physics var fragment_collision_layer:int = 1
@export_flags_3d_physics var fragment_collision_mask:int = 1
@export var explosion_speed:float = 6
@export var min_frag_lifetime:float = 1.2
@export var max_frag_lifetime:float = 1.8
@export var hitbox:Area3D
@export var break_sound: AudioStream = null
@export var original_model:MeshInstance3D = null
@export var fragments_node:Node3D = null
@export var pieces_node:Node3D = null

const FRAGMENT_SCENE:PackedScene = preload("res://Tile-RPG/Breakables/fragment.tscn")
var audio_player_3d: AudioStreamPlayer3D = null
var explode_origin:Vector3 = Vector3.ZERO

func _ready() -> void:
	_create_fragments()
	hitbox.area_entered.connect(_on_area_entered)
	audio_player_3d = AudioStreamPlayer3D.new()
	add_child(audio_player_3d)
	audio_player_3d.stream = break_sound

func _on_area_entered(area: Area3D) -> void:
	print("entered box")
	#Maybe need more precise position?
	if area.get_parent() is Player:
		print("player entered")
		explode_origin = area.global_position
		_explode()
		
func _explode() -> void:
	hitbox.monitoring = false
	original_model.visible = false
	
	for frag:Fragment in fragments_node.get_children():
		var vel:Vector3 = (frag.global_transform.origin - explode_origin) * explosion_speed
		frag.explode(vel)
	
	var last_frag:Fragment = fragments_node.get_children().back()
	last_frag.dissolved.connect(queue_free)
	
func _play_sound() -> void:
	audio_player_3d.global_position = explode_origin
	audio_player_3d.play()

#Run this code in editor
func _create_fragments() -> void:
	for mesh:MeshInstance3D in pieces_node.get_children():
		var new_fragment:Fragment = FRAGMENT_SCENE.instantiate()
		new_fragment.init_from_mesh(mesh)
		new_fragment.collision_layer = fragment_collision_layer
		new_fragment.collision_mask = fragment_collision_mask
		fragments_node.add_child(new_fragment) # "true" makes it persistent in editor
		#fragments_node.set_editable_instance(new_fragment,true)
		
		#mesh.queue_free(
	print("frag size: ", len(fragments_node.get_children()))
