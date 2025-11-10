extends Node3D
class_name Effect

signal effect_done

@export var start_on_spawn:bool = false
@export var looping:bool = false
@export var animation_player:AnimationPlayer = null

const PLAY_STRING:String = "play_effect"

func _ready() -> void:
	effect_done.connect(queue_free)
	
	if start_on_spawn: play_effect()

func play_effect() -> void:
	animation_player.play(PLAY_STRING)
