extends Control
class_name XButton

signal x_pressed

@export var button: Button = null
@export var close_button_sound:AudioStream = null
@export var select_glow: TextureRect = null

func _ready() -> void:
	button.pressed.connect(func(): 
		x_pressed.emit()
		GlobalSignals.play_audio.emit(close_button_sound, AudioManager.AUDIO_TYPE.UI)
		select_glow.visible = false )
	
	button.mouse_entered.connect(func(): select_glow.visible = true)
	button.mouse_exited.connect(func(): select_glow.visible = false)
	
