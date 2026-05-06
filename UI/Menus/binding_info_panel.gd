extends Control
class_name BindingInfoPanel

@export var cancel_button: ReusableButton = null
@export var rich_text_label: RichTextLabel = null

func _ready() -> void:
	cancel_button.texture_button.pressed.connect(hide)

func show_panel(bind_name:String) -> void:
	rich_text_label.text = "[wave amp=30.0 freq=3.0]" + "Binding " + bind_name + "[/wave]"
	show()
