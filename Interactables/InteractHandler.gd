extends Node
class_name InteractHandler

@export var player:Player
@export var indicator:Indicator
@export var label:Label3D
@export var no_interaction_sound:AudioStream
@export var interaction_sound:AudioStream

var interactables: Array[Interactable] = []
var current_interactee:Interactable = null
var disabled:bool = false

func _ready() -> void:
	set_process(false)
	GlobalSignals.combat_start.connect(_disable_interacting)
	GlobalSignals.combat_end.connect(_enable_interacting)

func _disable_interacting() -> void:
	disabled = true
	set_process(false)
	set_process_input(false)
	indicator.hide_indicator()
	
func _enable_interacting() -> void:
	disabled = false
	set_process_input(true)
	
	if interactables.is_empty(): return
	set_process(true)
	_show_right_interactee()

func _process(_delta: float) -> void:
	_show_right_interactee()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		_interact()

func _interact() -> void:
	if current_interactee == null:
		GlobalSignals.play_audio.emit(no_interaction_sound, AudioManager.AUDIO_TYPE.UI)
		return
		
	GlobalSignals.play_audio.emit(interaction_sound, AudioManager.AUDIO_TYPE.UI)
	
	if current_interactee.face_interactable:
		player.rotate_towards_point(current_interactee.indicator_place.global_position)
		await player.rotation_complete
	_interact_with_interactable()
	
func _interact_with_interactable() -> void:
	current_interactee.interact()
	if current_interactee == null :
		interactables.clear()
		return
	if current_interactee.oneshot:
		interactables.erase(current_interactee)
		current_interactee.handle_oneshot()
		_show_right_interactee()
		

func add_interactable(inter:Interactable) -> void:
	interactables.append(inter)
	inter.player = self.player
	_show_right_interactee()
	
	if disabled: return
	if len(interactables) > 1: set_process(true)
	else: set_process(false)
	
func remove_interactable(inter:Interactable) -> void:
	if interactables.has(inter):
		interactables.erase(inter)
		_show_right_interactee()
	
	if disabled: return
	if len(interactables) > 1: set_process(true)
	else: set_process(false)
	
func _show_right_interactee() -> void:
	if disabled: return
	
	if interactables.is_empty():
		if current_interactee == null: return
		current_interactee.hide_indicator()
		current_interactee = null
		return

	var closest:Interactable = _get_closest_interactee()
	if current_interactee != closest:
		if current_interactee != null:
			current_interactee.hide_indicator(true)

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
