extends Control
class_name MainMenu

@onready var return_button: ReusableButton = $PanelContainer/VBoxContainer/ReturnButton
@onready var options_button: ReusableButton = $PanelContainer/VBoxContainer/OptionsButton
@onready var load_button: ReusableButton = $PanelContainer/VBoxContainer/LoadButton
@onready var exit_button: ReusableButton = $PanelContainer/VBoxContainer/ExitButton

var exit_game:Callable = func(): get_tree().quit()

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	return_button.texture_button.pressed.connect(hide)
	exit_button.texture_button.pressed.connect(exit_game)
