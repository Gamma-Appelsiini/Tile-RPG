extends Node
class_name InteractHandler

@export var player:Player
@export var indicator:Indicator
@export var label:Label3D
@export var no_interaction_sound:AudioStream
@export var interaction_sound:AudioStream

var interactables: Array[Interactable] = []
var current_interactee:Interactable = null
var interactable:Interactable = null
var disabled:bool = false
var interacting:bool = false
var indicators:Array[Indicator] = []
var labels:Array[Label3D] = []

func _ready() -> void:
	set_process(false)
	GlobalSignals.combat_start.connect(_disable_interacting)
	GlobalSignals.combat_end.connect(_enable_interacting)
	_add_indicators()

func _add_indicators() -> void:
	indicators = [indicator]
	indicator = indicator.duplicate()
	add_child(indicator)
	indicators.push_back(indicator)
	indicator = indicator.duplicate()
	add_child(indicator)
	indicators.push_back(indicator)
	
	labels = [label]
	label = label.duplicate()
	add_child(label)
	labels.push_back(label)
	label = label.duplicate()
	add_child(label)
	labels.push_back(label)

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
	if player.character_state == GameCharacter.CharacterState.INTERACTING or interacting: return
	if current_interactee == null:
		GlobalSignals.play_audio.emit(no_interaction_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	interacting = true
	#current_interactee can move away while interacting
	interactable = current_interactee

	if interactable.interact_position:
		player.move_to_point(interactable.interact_position.global_position)
		await player.move_complete
	
	if interactable.face_interactable:
		player.rotate_towards_point(interactable.indicator_place.global_position)
		await player.rotation_complete

	if interactable.interact_animation != CharacterModelHandler.CharAnimation.NULL:
		player.enter_interact_state(interactable.interact_animation)
		if interactable.INTERACT_DELAYS.has(interactable.interact_animation):
			await get_tree().create_timer(interactable.INTERACT_DELAYS[interactable.interact_animation]).timeout

	_interact_with_interactable()
	interactable = null
	interacting = false
	
func _interact_with_interactable() -> void:
	GlobalSignals.play_audio.emit(interaction_sound, AudioManager.AUDIO_TYPE.UI)
	interactable.interact()
	
	if interactable == null :
		interactables.clear()
		return
	if interactable.oneshot:
		interactables.erase(interactable)
		interactable.handle_oneshot()
		_show_right_interactee()
		
func show_indicator(new_interactable:Interactable) -> void:
	var indicator_place:Node3D = new_interactable.get_interact_pos()
	
	var free_indicator:Indicator = null
	if new_interactable.indicator != null: free_indicator = new_interactable.indicator
	else:
		for ind:Indicator in indicators: if ind.visible == false: free_indicator = ind
		if free_indicator == null: free_indicator = indicators[0]
	
	free_indicator.hide()
	free_indicator.global_position = indicator_place.global_position + Vector3(0,0.1,0)
	free_indicator.reset_physics_interpolation()
	free_indicator.show_indicator()
	
	var free_label:Label3D = null
	if new_interactable.label != null: free_label = new_interactable.label
	else:
		for lab:Label3D in labels: if lab.visible == false: free_label = lab
		if free_label == null: free_label = labels[0]
	
	free_label.hide()
	free_label.text = new_interactable.interact_text
	free_label.global_position = indicator_place.global_position
	free_label.reset_physics_interpolation()
	
	free_label.modulate.a = 0
	free_label.show()
	var tween:Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tween.tween_property(free_label, "modulate:a", 1, .15)
	tween.tween_property(free_label, "outline_modulate:a", 1, .15)
	
	new_interactable.indicator = free_indicator
	new_interactable.label = free_label

func hide_indicator(new_interactable:Interactable) -> void:
	if new_interactable.indicator == null: return
	if new_interactable.label == null: return
	
	new_interactable.indicator.hide_indicator()
	
	var tween:Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_interactable.label, "modulate:a", 0, .15)
	tween.tween_property(new_interactable.label, "outline_modulate:a", 0, .15)
	await tween.finished
	new_interactable.label.hide()
	
	new_interactable.indicator = null
	new_interactable.label = null

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
		hide_indicator(current_interactee)
		current_interactee = null
		return

	var closest:Interactable = _get_closest_interactee()
	if current_interactee != closest:
		if current_interactee != null:
			hide_indicator(current_interactee)

		current_interactee = closest
		show_indicator(current_interactee)
		
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
