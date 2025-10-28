extends Control
class_name CombatUI

signal portraits_added

@export var portrait_slide_sound:AudioStream = null
@export var turn_container: HBoxContainer = null
@export var info_label: Label = null
@export var turn_haver_container: VBoxContainer = null

const TURN_PORTRAIT := preload("uid://cerdi7wt14odo")

var turn_haver_portrait:TurnPortrait = null

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Left Click"):
		turn_haver_portrait = turn_haver_container.get_children()[0]
		_animate_turn_haver_away()

func _ready() -> void:
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)

func _on_combat_start() -> void:
	self.visible = true

func _on_combat_end() -> void:
	self.visible = false
	for tp:TurnPortrait in turn_container: tp.queue_free()

func add_characters(combatants:Array[GameCharacter]) -> void:
	for gchar:GameCharacter in combatants:
		var new_portrait:TurnPortrait = TURN_PORTRAIT.instantiate()
		new_portrait.set_character(gchar)
		#new_portrait.modulate.a = 0
		turn_container.add_child(new_portrait)
		_animate_portrait_to_pos(new_portrait)
		await get_tree().create_timer(0.2).timeout
	
	portraits_added.emit()

func update_portraits(combatants:Array[GameCharacter]) -> void:
	var portraits_to_remove:Array[TurnPortrait] = []
	var portraits_to_keep:Array[TurnPortrait] = []
	
	for tp:TurnPortrait in turn_container.get_children():
		if !combatants.has(tp.gchar):
			portraits_to_remove.push_back(tp)
		else: portraits_to_keep.push_back(tp)
			
	#Animate portraits smoothly to their new places inside turn_container and remove not needed portraits smoothly animating them away
	#Combatants is the order in the portraits should be. TurnPortrait has variable gchar that has which GameCharacter is in the portrait.
	
	# Animate removals (fade + slide out)
	for tp in portraits_to_remove:
		var tween := create_tween()
		tween.tween_property(tp, "modulate:a", 0.0, 0.3)
		tween.tween_property(tp, "position:x", tp.position.x + 50, 0.3)
		tween.finished.connect(func():
			if is_instance_valid(tp):
				tp.queue_free()
		)
	
	# Ensure container order matches combatants array
	var new_order:Array[TurnPortrait] = []
	for gchar in combatants:
		var portrait := portraits_to_keep.filter(func(p): return p.gchar == gchar)
		if portrait.size() > 0:
			new_order.push_back(portrait[0])
	
	# Reorder nodes according to combatants order
	for i in range(new_order.size()):
		turn_container.move_child(new_order[i], i)
	
	# Animate smooth movement of portraits to new positions
	# We wait one frame to ensure layout updates before tweening
	await get_tree().process_frame
	for tp in new_order:
		var tween := create_tween()
		var target_pos := tp.position  # new layout position
		tp.position = tp.position.lerp(target_pos, 0.0) # keep current pos
		tween.tween_property(tp, "position", target_pos, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func set_turn_haver(gchar:GameCharacter) -> void:
	_animate_turn_haver_away(gchar)

func _animate_turn_haver_in(gchar:GameCharacter) -> void:
	var new_portrait:TurnPortrait = TURN_PORTRAIT.instantiate()
	new_portrait.set_character(gchar)
	new_portrait.set_active()
	turn_haver_portrait = new_portrait
	turn_haver_container.add_child(new_portrait)
	_animate_portrait_to_pos(new_portrait)

func _animate_turn_haver_away(replacer_char:GameCharacter = null) -> void:
	if !turn_haver_portrait:
		if replacer_char: _animate_turn_haver_in(replacer_char)
		return
	
	var animation_portrait:TurnPortrait = turn_haver_portrait.duplicate()
	add_child(animation_portrait)
	animation_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	animation_portrait.size.y = turn_haver_portrait.get_parent().size.y
	animation_portrait.position = Vector2(-turn_haver_portrait.get_parent().size.x /2,0)
	
	turn_haver_portrait.queue_free()
	
	var viewport_size:Vector2 = get_viewport_rect().size
	var offset:Vector2 = Vector2(0,viewport_size.y * 0.4)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(animation_portrait,"modulate:a", 0, 0.9)
	tween.tween_property(animation_portrait,"position", animation_portrait.position + offset, 1)
	
	await tween.finished
	animation_portrait.queue_free()
	turn_haver_portrait = null
	
	if replacer_char: _animate_turn_haver_in(replacer_char)

func _animate_portrait_to_pos(portrait:TurnPortrait) -> void:
	portrait.modulate.a = 0
	var animation_portrait:TurnPortrait = portrait.duplicate()
	animation_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	self.add_child(animation_portrait)
	#animation_portrait.custom_minimum_size = portrait.size
	animation_portrait.size.y = portrait.get_parent().size.y
	
	
	var viewport_size:Vector2 = get_viewport_rect().size
	var offset:Vector2 = Vector2(0,viewport_size.y * 0.4)
	animation_portrait.global_position = animation_portrait.global_position + offset
	
	
	GlobalSignals.play_audio.emit(portrait_slide_sound, AudioManager.AUDIO_TYPE.UI)
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(animation_portrait,"modulate:a", 1, .4)
	tween.tween_property(animation_portrait,"global_position", portrait.global_position, .8)
	
	await tween.finished
	portrait.modulate.a = 1
	animation_portrait.queue_free()

func show_text(new_text:String, color:Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	var new_label:Label = info_label.duplicate()
	new_label.add_theme_color_override("font_color",color)
	add_child(new_label)
	new_label.visible = true
	new_label.text = new_text
	new_label.modulate.a = 0
	
	var viewport_size:Vector2 = get_viewport_rect().size
	var offset:Vector2 = Vector2(0,viewport_size.y * 0.4)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(new_label,"modulate:a", 1, 1)
	tween.tween_property(new_label,"global_position", new_label.global_position + offset, 1)
	
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	var tween2:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween2.tween_property(new_label,"modulate:a", 0, 0.3)
	await tween2.finished
	new_label.queue_free()
