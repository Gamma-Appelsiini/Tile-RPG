extends Control
class_name CombatUI

signal portraits_added
signal portraits_reordered

@export var portrait_slide_sound:AudioStream = null
@export var turn_container: HBoxContainer = null
@export var info_label: Label = null
@export var turn_haver_container: VBoxContainer = null

const TURN_PORTRAIT := preload("uid://cerdi7wt14odo")
const PORTRAIT_MOVE_TIME:float = 0.3
const PORTRAIT_X_RATIO:float = 0.75

var combat_manager:CombatManager = null
var turn_haver_portrait:TurnPortrait = null

func _ready() -> void:  
	GlobalSignals.combat_start.connect(_on_combat_start)
	GlobalSignals.combat_end.connect(_on_combat_end)

func _on_combat_start() -> void:
	combat_manager = GlobalSignals.combat_manager
	self.visible = true

func _on_combat_end() -> void:
	self.visible = false
	for tp:TurnPortrait in turn_container.get_children(): tp.queue_free()
	for tp:TurnPortrait in turn_haver_container.get_children(): tp.queue_free()

func _get_portrait_size() -> Vector2:
	var p_height:float = get_viewport_rect().size.y * 0.1
	var p_width:float = p_height * PORTRAIT_X_RATIO
	var p_size:Vector2 = Vector2(p_width, p_height)
	
	return p_size

func _get_border_type(gchar:GameCharacter) -> TurnPortrait.BORDER_TYPE:
	var border_type:TurnPortrait.BORDER_TYPE = TurnPortrait.BORDER_TYPE.ENEMY
	if gchar is Player: border_type = TurnPortrait.BORDER_TYPE.PLAYER
	elif combat_manager.player_team.has(gchar): border_type = TurnPortrait.BORDER_TYPE.FRIENDLY
	
	return border_type

func add_characters(combatants:Array[GameCharacter]) -> void:
	for gchar:GameCharacter in combatants:
		var new_portrait:TurnPortrait = TURN_PORTRAIT.instantiate()
		var border_type:TurnPortrait.BORDER_TYPE = _get_border_type(gchar)
		new_portrait.set_character(gchar, border_type)
		turn_container.add_child(new_portrait)
		
		new_portrait.modulate.a = 0
		_animate_portrait_in_out(new_portrait,false, false)
		await get_tree().create_timer(PORTRAIT_MOVE_TIME).timeout
		new_portrait.modulate.a = 1
	
	portraits_added.emit()

func update_portraits(combatants:Array[GameCharacter]) -> void:
	var portraits_to_remove:Array[TurnPortrait] = []
	
	for tp:TurnPortrait in turn_container.get_children():
		if !combatants.has(tp.gchar):
			portraits_to_remove.push_back(tp)
			
	for tp:TurnPortrait in portraits_to_remove:
		_squeeze_portrait_away(tp)
	
	await get_tree().create_timer(PORTRAIT_MOVE_TIME).timeout
	_reorder_portraits(combatants)
	await portraits_reordered
	portraits_added.emit()
	
func _reorder_portraits(combatants:Array[GameCharacter]) -> void:
	var place:int = 0
	for tp:TurnPortrait in turn_container.get_children():
		if combatants[place] != tp.gchar:
			_animate_portrait_to_place(combatants[place], place)
		
		place += 1
	
	await get_tree().create_timer(PORTRAIT_MOVE_TIME).timeout
	portraits_reordered.emit()

func _animate_portrait_to_place(gchar:GameCharacter, end_place:int) -> void:
	var from_portrait:TurnPortrait = null
	for tp:TurnPortrait in turn_container.get_children():
		if tp.gchar == gchar:
			from_portrait = tp
			break
	
	var end_portrait:TurnPortrait = turn_container.get_children()[end_place]
	var from_place:int = turn_container.get_children().find(from_portrait)
	var spot_amount:int = (end_place - from_place)
	var offset:Vector2 = Vector2(_get_portrait_size().x * spot_amount, 0)
	
	var animation_portrait:TurnPortrait = from_portrait.duplicate()
	add_child(animation_portrait)
	animation_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	animation_portrait.size = _get_portrait_size()
	animation_portrait.position = _calculate_x_offset(from_portrait, true) + Vector2(get_viewport_rect().size.x * 0.5, 0)
	
	from_portrait.modulate.a = 0
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(animation_portrait,"position", animation_portrait.position + offset, PORTRAIT_MOVE_TIME * 9)
	
	await tween.finished
	end_portrait.set_character(gchar)
	from_portrait.modulate.a = 1
	animation_portrait.queue_free()

func _squeeze_portrait_away(tp:TurnPortrait) -> void:
	_animate_portrait_in_out(tp,true)
	tp.modulate.a = 0
	if tp.nine_patch_rect: tp.nine_patch_rect.free()
	tp.custom_minimum_size.y = _get_portrait_size().y
	tp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(tp,"custom_minimum_size:y", 0, PORTRAIT_MOVE_TIME - 0.05)
	await tween.finished
	tp.queue_free()

func _calculate_x_offset(tp:TurnPortrait, out:bool = false) -> Vector2:
	var portraits_place:int = turn_container.get_children().find(tp) + 1
	if !out: portraits_place = turn_container.get_child_count()
	
	if portraits_place == 1: return Vector2(0, 0)
	var x_offset:Vector2 = Vector2(portraits_place * (_get_portrait_size().x),0) - Vector2(_get_portrait_size().x, 0)
	return x_offset

func _animate_portrait_in_out(tp:TurnPortrait, out:bool, turn_haver:bool = false) -> void:
	if tp == null: return
	
	var animation_portrait:TurnPortrait = tp.duplicate()
	animation_portrait.modulate.a = 1
	add_child(animation_portrait)
	
	animation_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	animation_portrait.size = _get_portrait_size()
	animation_portrait.position = _calculate_x_offset(tp, out) + Vector2(get_viewport_rect().size.x * 0.5, 0)

	if turn_haver:
		animation_portrait.size = Vector2(get_viewport_rect().size.x * (0.5 - 0.435), get_viewport_rect().size.y * 0.15)
		animation_portrait.position = Vector2(get_viewport_rect().size.x * 0.435, 0)
	
	var offset:Vector2 = Vector2(0, get_viewport_rect().size.y * 0.1)
	var modulation:int = 0
	if !out:
		modulation = 1
		animation_portrait.modulate.a = 0
		animation_portrait.position = animation_portrait.position - offset
	
	GlobalSignals.play_audio.emit(portrait_slide_sound, AudioManager.AUDIO_TYPE.UI)
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(animation_portrait,"modulate:a", modulation, PORTRAIT_MOVE_TIME)
	tween.tween_property(animation_portrait,"position", animation_portrait.position + offset, PORTRAIT_MOVE_TIME + 0.01)
	
	await tween.finished
	animation_portrait.queue_free()

func set_turn_haver(new_turn_haver:GameCharacter) -> void:
	if turn_haver_portrait != null:
		turn_haver_portrait.modulate.a = 0
		_animate_portrait_in_out(turn_haver_portrait, true, true)
		await get_tree().create_timer(PORTRAIT_MOVE_TIME).timeout
		turn_haver_portrait.queue_free()
		turn_haver_portrait = null
		
	if new_turn_haver == null: return
	for tp:TurnPortrait in turn_container.get_children():
		if tp.gchar == new_turn_haver:
			_squeeze_portrait_away(tp)
			break
	
	var new_portrait:TurnPortrait = TURN_PORTRAIT.instantiate()
	var border_type:TurnPortrait.BORDER_TYPE = _get_border_type(new_turn_haver)
	new_portrait.set_character(new_turn_haver, border_type)
	new_portrait.set_active()
	turn_haver_portrait = new_portrait
	turn_haver_container.add_child(new_portrait)
	new_portrait.modulate.a = 0
	_animate_portrait_in_out(new_portrait, false, true)
	await get_tree().create_timer(PORTRAIT_MOVE_TIME).timeout
	new_portrait.modulate.a = 1

func show_text(new_text:String, color:Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	var new_label:Label = info_label.duplicate()
	new_label.add_theme_color_override("font_color",color)
	add_child(new_label)
	new_label.visible = true
	new_label.text = new_text
	new_label.modulate.a = 0
	
	var viewport_size:Vector2 = get_viewport_rect().size
	var offset:Vector2 = Vector2(0,viewport_size.y * 0.2)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(new_label,"modulate:a", 1, 1)
	tween.tween_property(new_label,"global_position", new_label.global_position + offset, 1)
	
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	var tween2:Tween = create_tween().set_ease(Tween.EASE_IN)
	tween2.tween_property(new_label,"modulate:a", 0, 0.3)
	await tween2.finished
	new_label.queue_free()
