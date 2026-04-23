extends PanelContainer
class_name InteractPrompt

@export var button_label: Label = null
@export var text_label: Label = null

var position_node:Node3D = null
var current_camera:Camera3D = null

func set_interact_text(interact_text:String):
	button_label.text = _get_input_string("Interact")
	text_label.text = interact_text

func _get_input_string(action_name: String) -> String:
	var events:Array[InputEvent] = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var event:InputEvent = events[0]
		var button_name: String = OS.get_keycode_string( event.physical_keycode )
		return button_name

	return "Unknown"

func _process(_delta: float) -> void:
	if self.visible == false:
		set_process(false)
		return

	_update_pos()

func _update_pos() -> void:
	var screen_position:Vector2 = current_camera.unproject_position(position_node.global_transform.origin)
	var offset:Vector2 = Vector2(-self.size.x / 2, -self.size.y / 3)
	self.global_position = screen_position + offset

func show_prompt(new_interactable:Interactable) -> void:
	position_node = new_interactable.get_interact_pos()
	set_interact_text(new_interactable.interact_text)
	current_camera =  get_viewport().get_camera_3d()
	
	modulate.a = 0
	show()
	set_process(true)
	
	var tween:Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1, .18)

func hide_prompt() -> void:
	var tween:Tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, 0.18)
	
	await tween.finished
	hide()
