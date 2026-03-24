extends PanelContainer
class_name SettingsPanel

@export var resolution_option: OptionButton = null
@export var window_mode_option: OptionButton = null
@export var main_volume_slider: HSlider = null
@export var sfx_volume_slider: HSlider = null
@export var ui_volume_slider: HSlider = null
@export var music_volume_slider: HSlider = null
@export var return_button: ReusableButton = null

const RESOLUTIONS:Array[Vector2i] = [Vector2i(960,540), Vector2i(1280,720), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3840,2160)]
var sliders:Dictionary[AudioManager.AUDIO_TYPE, HSlider] = {
	AudioManager.AUDIO_TYPE.MASTER: main_volume_slider,
	AudioManager.AUDIO_TYPE.SOUND_EFFECT: sfx_volume_slider,
	AudioManager.AUDIO_TYPE.UI: ui_volume_slider,
	AudioManager.AUDIO_TYPE.MUSIC: music_volume_slider,
}

var game_save_data:Dictionary = {}

func _ready() -> void:
	_fill_resolutions()
	window_mode_option.item_selected.connect(_apply_window_mode)
	return_button.texture_button.pressed.connect(hide)
	
	main_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.MASTER))
	sfx_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.SOUND_EFFECT))
	ui_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.UI))
	music_volume_slider.value_changed.connect(_audio_setting_changed.bind(AudioManager.AUDIO_TYPE.MUSIC))

func _audio_setting_changed(value: float, audio_type:AudioManager.AUDIO_TYPE) -> void:
	GlobalSignals.change_volume.emit(audio_type, value)
	save_to_data(game_save_data)

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

	var center_pos := screen_rect.position + (screen_rect.size - window_size) / 2
	DisplayServer.window_set_position(center_pos)

func load_from_data(save_data:Dictionary) -> void:
	game_save_data = save_data
	var setting_data:Dictionary = save_data["settings"]
	
	resolution_option.select(setting_data["resolution"])
	window_mode_option.select(setting_data["window_mode"])
	
	if !setting_data.has("main_volume"): return
	
	main_volume_slider.value = setting_data["main_volume"]
	music_volume_slider.value = setting_data["music_volume"]
	sfx_volume_slider.value = setting_data["sfx_volume"]
	ui_volume_slider.value = setting_data["ui_volume"]
	
func save_to_data(save_data:Dictionary) -> void:
	if game_save_data == {}: return
	
	var setting_data:Dictionary = {}
	setting_data["window_mode"] = window_mode_option.selected
	setting_data["resolution"] = resolution_option.selected
	
	setting_data["main_volume"] = main_volume_slider.value
	setting_data["music_volume"] = music_volume_slider.value
	setting_data["sfx_volume"] = sfx_volume_slider.value
	setting_data["ui_volume"] = ui_volume_slider.value
	
	save_data["settings"] = setting_data
