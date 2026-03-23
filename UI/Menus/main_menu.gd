extends Control
class_name MainMenu

@export var return_button: ReusableButton = null
@export var options_button: ReusableButton = null
@export var load_button: ReusableButton = null
@export var exit_button: ReusableButton = null

var exit_game:Callable = func(): get_tree().quit()

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	return_button.texture_button.pressed.connect(hide)
	exit_button.texture_button.pressed.connect(exit_game)
