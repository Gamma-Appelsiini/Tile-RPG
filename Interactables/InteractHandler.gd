extends Node
class_name InteractHandler

@export var player:Player
@export var indicator:Indicator
@export var no_interaction_sound:AudioStream
@export var interaction_sound:AudioStream
@export var interact_prompt: InteractPrompt = null

var interactables: Array[Interactable] = []
var current_interactee:Interactable = null
var interactable:Interactable = null
var indicators:Array[Indicator] = []
var prompts:Array[InteractPrompt] = []

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
	
	prompts = [interact_prompt]
	interact_prompt = interact_prompt.duplicate()
	add_child(interact_prompt)
	prompts.push_back(interact_prompt)
	interact_prompt = interact_prompt.duplicate()
	add_child(interact_prompt)
	prompts.push_back(interact_prompt)

func _disable_interacting() -> void:
	set_process(false)
	set_process_input(false)
	for child in get_children(): child.hide()
	current_interactee = null
	
func _enable_interacting() -> void:
	set_process_input(true)
	if interactables.is_empty(): return
	set_process(true)

func _process(_delta: float) -> void:
	_show_right_interactee()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		_interact()

func _interact() -> void:
	if current_interactee == null:
		GlobalSignals.play_audio.emit(no_interaction_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	interactable = current_interactee
	_disable_interacting()

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

	await _interact_with_interactable()
	interactable = null
	
func _interact_with_interactable() -> void:
	GlobalSignals.play_audio.emit(interaction_sound, AudioManager.AUDIO_TYPE.UI)
	if interactable.disable_movement: GlobalSignals.disable_player_movement.emit()
	interactable.interact()
	
	#Some interactables give signal too early and they have to wait with timer?
	await interactable.interact_complete
	if interactable.disable_movement: GlobalSignals.enable_player_movement.emit()
	_enable_interacting()

	if interactable.oneshot:
		interactables.erase(interactable)
		interactable.handle_oneshot()

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
	new_interactable.indicator = free_indicator
	
	_show_prompt(new_interactable)
	

func _show_prompt(new_interactable:Interactable) -> void:
	var free_prompt:InteractPrompt = null
	if new_interactable.prompt != null: free_prompt = new_interactable.prompt
	else:
		for prompt:InteractPrompt in prompts: if prompt.visible == false: free_prompt = prompt
		if free_prompt == null: free_prompt = prompts[0]
	
	free_prompt.show_prompt(new_interactable)
	new_interactable.prompt = free_prompt

func hide_indicator(new_interactable:Interactable) -> void:
	if new_interactable.indicator == null: return
	if new_interactable.prompt == null: return
	
	new_interactable.indicator.hide_indicator()
	new_interactable.prompt.hide_prompt()
	
	new_interactable.indicator = null
	new_interactable.prompt = null

func add_interactable(inter:Interactable) -> void:
	interactables.append(inter)
	inter.player = self.player
	_show_right_interactee()
	
	if len(interactables) > 1: set_process(true)
	else: set_process(false)
	
func remove_interactable(inter:Interactable) -> void:
	if interactables.has(inter):
		interactables.erase(inter)
		_show_right_interactee()
	
	if len(interactables) > 1: set_process(true)
	else: set_process(false)
	
func _show_right_interactee() -> void:
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
