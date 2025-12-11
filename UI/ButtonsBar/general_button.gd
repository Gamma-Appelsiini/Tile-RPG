extends PanelContainer
class_name GenericButton

signal button_pressed

@export var select_rect: TextureRect = null
@export var button: Button = null
@export var button_press_sound:AudioStream = null

func _ready() -> void:
	button.mouse_entered.connect( func(): select_rect.show() )
	button.mouse_exited.connect( func(): select_rect.hide()  )
	button.pressed.connect(func(): 
		GlobalSignals.play_audio.emit(button_press_sound, AudioManager.AUDIO_TYPE.UI)
		button_pressed.emit() )

	
