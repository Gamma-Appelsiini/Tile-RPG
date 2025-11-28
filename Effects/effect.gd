extends Node3D
class_name Effect

signal effect_done

@export var start_on_spawn:bool = false
@export var looping:bool = false
@export var start_sound:AudioStream = null
@export var end_sound:AudioStream = null
@export var effect_sound:AudioStream = null
@export var animation_player:AnimationPlayer = null
@export var starting_animation:String = ""
@export var ending_animation:String = ""

const PLAY_STRING:String = "play_effect"

var asp:AudioStreamPlayer3D = null

func _ready() -> void:
	_handle_start()

func _handle_start() -> void:
	effect_done.connect(queue_free)
	if looping and effect_sound:
		asp = AudioStreamPlayer3D.new()
		asp.stream = effect_sound
		add_child(asp)
	
	if start_on_spawn: play_effect()


func play_effect() -> void:
	if starting_animation != "":
		GlobalSignals.play_audio.emit(start_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
		animation_player.play(starting_animation)
		await get_tree().create_timer(animation_player.current_animation_length).timeout
	
	animation_player.play(PLAY_STRING)
	
	if !looping:
		await get_tree().create_timer(animation_player.current_animation_length).timeout
		end_effect()
	else: asp.play()

func end_effect() -> void:
	animation_player.stop()
	
	if ending_animation == starting_animation and starting_animation != "":
		animation_player.play_backwards(starting_animation)
	elif ending_animation != "":
		animation_player.play(ending_animation)
	
	if animation_player.is_playing():
		await get_tree().create_timer(animation_player.current_animation_length).timeout
	
	GlobalSignals.play_audio.emit(end_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
	effect_done.emit()
	queue_free()

func _play_effect_sound() -> void:
	GlobalSignals.play_audio.emit(effect_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position)
