extends Node
class_name InteractHandler

@export var player:Player
@export var indicator:Indicator
@export var label:Label3D
@export var no_interaction_sound:AudioStream
@export var interaction_sound:AudioStream
@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D

var interactables: Array[Interactable] = []
var current_interactee:Interactable = null
var input_enabled:bool = true

func _process(_delta: float) -> void:
	if len(interactables) > 1: _show_right_interactee()

func _input(event: InputEvent) -> void:
	if !input_enabled: return
	
	if event.is_action_pressed("Interact"):
		_interact()

func _interact() -> void:
	if current_interactee == null:
		audio_stream_player_3d.stream = no_interaction_sound
		audio_stream_player_3d.play()
		return
		
	audio_stream_player_3d.stream = interaction_sound
	audio_stream_player_3d.play()
	_interact_with_interactable()
	
func _interact_with_interactable() -> void:
	current_interactee.interact()
	if current_interactee.oneshot:
		interactables.erase(current_interactee)
		current_interactee.handle_oneshot()
		_show_right_interactee()
		

func add_interactable(inter:Interactable) -> void:
	interactables.append(inter)
	inter.player = self.player
	_show_right_interactee()
	
func remove_interactable(inter:Interactable) -> void:
	if interactables.has(inter):
		interactables.erase(inter)
		_show_right_interactee()
	
func _show_right_interactee() -> void:
	if interactables.is_empty():
		if current_interactee == null: return
		current_interactee.hide_indicator()
		current_interactee = null
		return

	var closest:Interactable = _get_closest_interactee()
	if current_interactee != closest:
		if current_interactee != null:
			current_interactee.hide_indicator()

		#TODO fix indicator hiding in multiple interaction areas
		current_interactee = closest
		current_interactee.show_indicator(indicator,label)
		
func _get_closest_interactee() -> Interactable:
	var closest:Interactable = interactables[0]
	if len(interactables) == 1: return closest
	
	var closest_distance:float = player.global_transform.origin.distance_to(closest.global_transform.origin)
	
	for inter:Interactable in interactables:
		var distance:float = player.global_transform.origin.distance_to(inter.global_transform.origin)
		if distance < closest_distance:
			closest = inter
			closest_distance = distance
	
	return closest
