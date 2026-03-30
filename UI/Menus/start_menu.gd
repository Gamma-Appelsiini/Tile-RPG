extends Control
class_name StartMenu

@export var level_loader:LevelLoader = null
@export var new_game_button: ReusableButton = null
@export var load_game_button: ReusableButton = null
@export var settings_button: ReusableButton = null
@export var exit_button: ReusableButton = null
@export var settings_panel: SettingsPanel = null
@export var buttons_container: VBoxContainer = null
@export var load_panel: LoadPanel = null
@export var save_slot_panel: SaveSlotPanel = null

func _ready() -> void:
	load_panel.level_loader = level_loader
	save_slot_panel.level_loader = level_loader
	_connect_buttons()
	
func _connect_buttons() -> void:
	settings_panel.visibility_changed.connect(func(): if !settings_panel.visible: buttons_container.show())
	settings_button.texture_button.pressed.connect(func(): 
		buttons_container.hide()
		settings_panel.show()
		)
		
	exit_button.texture_button.pressed.connect(func(): get_tree().quit())
	new_game_button.texture_button.pressed.connect(_new_game)
	load_game_button.texture_button.pressed.connect(_load_game)

func _load_game() -> void:
	buttons_container.hide()
	load_panel.show()

func _new_game() -> void:
	buttons_container.hide()
	save_slot_panel.show()
