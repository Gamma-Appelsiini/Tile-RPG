extends Control
class_name CombatUI

signal portraits_added

@export var portrait_slide_sound:AudioStream = null
@export var turn_container: HBoxContainer = null
@export var info_label: Label = null
@export var turn_haver_container: VBoxContainer = null

const TURN_PORTRAIT := preload("uid://cerdi7wt14odo")

func _on_combat_start() -> void:
	pass
	
func add_characters(combatants:Array[GameCharacter]) -> void:
	for gchar:GameCharacter in combatants:
		var new_portrait:TurnPortrait = TURN_PORTRAIT.instantiate()
		new_portrait.set_character(gchar)
		new_portrait.modulate.a = 0
		turn_container.add_child(new_portrait)
		_animate_portrait_to_pos(new_portrait)
		await get_tree().create_timer(0.1).timeout
	
	portraits_added.emit()

func update_portraits(combatants:Array[GameCharacter]) -> void:
	pass

func set_turn_haver(gchar:GameCharacter) -> void:
	pass

func _animate_portrait_to_pos(portrait:TurnPortrait) -> void:
	var animation_portrait:TurnPortrait = portrait.duplicate()
	var viewport_size:Vector2 = get_viewport_rect().size
	var offset:Vector2 = Vector2(0,viewport_size.y * 0.4)
	animation_portrait.global_position = animation_portrait.global_position + offset
	
	GlobalSignals.play_audio.emit(portrait_slide_sound, AudioManager.AUDIO_TYPE.UI)
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(animation_portrait,"modulate:a", 1, 0.2)
	tween.tween_property(animation_portrait,"global_position", portrait.global_position, 0.6)
	
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
