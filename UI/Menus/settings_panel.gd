extends PanelContainer
class_name SettingsPanel

@export var load_settings_on_ready:bool = false
@export var resolution_option: OptionButton = null
@export var window_mode_option: OptionButton = null
@export var main_volume_slider: HSlider = null
@export var sfx_volume_slider: HSlider = null
@export var ui_volume_slider: HSlider = null
@export var music_volume_slider: HSlider = null
@export var return_button: ReusableButton = null
@export var binds_button: ReusableButton = null
@export var rebind_panel: RebindPanel = null

const SETTINGS_FILE_PATH:String = "res://Tile-RPG/SaveData/setting_data.bin"
const RESOLUTIONS:Array[Vector2i] = [Vector2i(960,540), Vector2i(1280,720), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3840,2160)]

var sliders:Dictionary[AudioManager.AUDIO_TYPE, HSlider] = {
	AudioManager.AUDIO_TYPE.MASTER: main_volume_slider,
	AudioManager.AUDIO_TYPE.SOUND_EFFECT: sfx_volume_slider,
	AudioManager.AUDIO_TYPE.UI: ui_volume_slider,
	AudioManager.AUDIO_TYPE.MUSIC: music_volume_slider,
}

var setting_data:Dictionary = {
	"window_mode": 0,
	"resolution": 3,
}

var game_save_data:Dictionary = {}

func _ready() -> void:
	_fill_resolutions()
	window_mode_option.item_selected.connect(_apply_window_mode)
	return_button.texture_button.pressed.connect(hide)
	binds_button.texture_button.pressed.connect(rebind_panel.show)
	
	main_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.MASTER))
	sfx_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.SOUND_EFFECT))
	ui_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.UI))
	music_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.MUSIC))
	
	visibility_changed.connect(func(): if !visible: _save_to_data())
	
	load_from_data()

func _audio_setting_changed(value: float, audio_type:AudioManager.AUDIO_TYPE) -> void:
	GlobalSignals.change_volume.emit(audio_type, value)

func _fill_resolutions() -> void:
	var id:int = 0
	for reso_vector:Vector2 in RESOLUTIONS:
		var reso_string:String = str(int(reso_vector.x)) + " x " + str(int(reso_vector.y)) 
		resolution_option.add_item(reso_string, id)
		id += 1
	
	resolution_option.item_selected.connect(_apply_resolution)

func _apply_window_mode(id:int) -> void:
	match id:
		0: #Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Exclusive Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2: #Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _apply_resolution(id:int) -> void:
	var new_resolution: Vector2i = Vector2i(RESOLUTIONS[id])
	DisplayServer.window_set_size(new_resolution)
	
	#Center screen
	var screen_id := DisplayServer.window_get_current_screen()
	var screen_rect := DisplayServer.screen_get_usable_rect(screen_id)
	var window_size := DisplayServer.window_get_size()

	var center_pos := screen_rect.position + Vector2i((screen_rect.size - window_size) / 2.0)
	DisplayServer.window_set_position(center_pos)

func _load_settings_file() -> bool:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		print("No settings file")
		return false

	var file:FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	var data:Dictionary = file.get_var()
	setting_data = data.duplicate()

	file.close()
	return true

func load_from_data() -> void:
	if !load_settings_on_ready: return
	if !_load_settings_file(): return
	
	resolution_option.select(setting_data["resolution"])
	_apply_resolution(resolution_option.selected)
	
	window_mode_option.select(setting_data["window_mode"])
	_apply_window_mode(window_mode_option.selected)
	
	main_volume_slider.value = setting_data["main_volume"]
	music_volume_slider.value = setting_data["music_volume"]
	sfx_volume_slider.value = setting_data["sfx_volume"]
	ui_volume_slider.value = setting_data["ui_volume"]
	
func _save_to_data() -> void:
	setting_data["window_mode"] = window_mode_option.selected
	setting_data["resolution"] = resolution_option.selected
	
	setting_data["main_volume"] = main_volume_slider.value
	setting_data["music_volume"] = music_volume_slider.value
	setting_data["sfx_volume"] = sfx_volume_slider.value
	setting_data["ui_volume"] = ui_volume_slider.value
	
	#Creates new file if does not exist
	var file:FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	file.store_var(setting_data.duplicate())
	file.close()
