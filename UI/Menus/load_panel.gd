extends PanelContainer
class_name LoadPanel

const SAVE_SLOT_STRINGS:Array[String] = ["slot1", "slot2", "slot3"]
const IMAGE_SUFFIX:String = ""

@export var v_box_container: VBoxContainer = null
@export var no_saves_label: Label = null
@export var return_button: ReusableButton = null

var level_loader:LevelLoader = null

func _ready() -> void:
	_set_save_files()
	return_button.texture_button.pressed.connect(func():
		get_parent().buttons_container.show()
		hide()
		)

func _set_save_files() -> void:
	var show_no_saves:bool = true

	for i:int in len(SAVE_SLOT_STRINGS):
		var file_path:String = level_loader.SAVE_FILE_PATH + SAVE_SLOT_STRINGS[i] + level_loader.SAVE_SUFFIX
		if !FileAccess.file_exists(file_path):
			v_box_container.get_children()[i+1].hide()
			continue
		
		show_no_saves = false
		_connect_load_button(i, file_path)
		_set_slot_screenshot(i)
		
	if show_no_saves: no_saves_label.show()

func _set_slot_screenshot(i:int) -> void:
	var img_path: String = level_loader.SAVE_FILE_PATH + SAVE_SLOT_STRINGS[i] + ".png"
	if FileAccess.file_exists(img_path):
		var image = Image.load_from_file(img_path)
		var texture = ImageTexture.create_from_image(image)
	
		var texture_rect: TextureRect = v_box_container.get_children()[i].get_children()[0].get_children()[0]
		texture_rect.texture = texture
		
func _connect_load_button(i:int, file_path:String) -> void:
	var load_button:ReusableButton = v_box_container.get_children()[i+1].get_children()[0].get_children()[2]
	load_button.texture_button.pressed.connect(func():
		level_loader.save_file_folder_path = level_loader.SAVE_FILE_PATH + SAVE_SLOT_STRINGS[i]
		level_loader.load_game_from_path.bind(file_path)
		get_parent().buttons_container.show()
		await get_tree().create_timer(0.5).timeout
		get_parent().hide()
		)
