extends PanelContainer
class_name SaveSlotPanel

@export var return_button: ReusableButton = null
@export var v_box_container: VBoxContainer = null

const SAVE_SLOT_STRINGS:Array[String] = ["slot1", "slot2", "slot3"]

var level_loader:LevelLoader = null

func _ready() -> void:
	return_button.texture_button.pressed.connect(func():
		get_parent().buttons_container.show()
		hide()
		)
	_set_save_files()
	
func _set_save_files() -> void:
	for i:int in len(SAVE_SLOT_STRINGS):
		var file_path:String = level_loader.SAVE_FILE_PATH + SAVE_SLOT_STRINGS[i] + level_loader.SAVE_SUFFIX
		if !FileAccess.file_exists(file_path):
			v_box_container.get_children()[i+1].get_children()[0].get_children()[1].text = "Empty save slot"

		_connect_load_button(i)

func _connect_load_button(i:int) -> void:
	var load_button:ReusableButton = v_box_container.get_children()[i+1].get_children()[0].get_children()[2]
	load_button.texture_button.pressed.connect(func():
		level_loader.save_file_folder_path = level_loader.SAVE_FILE_PATH + SAVE_SLOT_STRINGS[i]
		level_loader.new_game()
		get_parent().buttons_container.show()
		await get_tree().create_timer(0.5).timeout
		get_parent().hide()
		)
