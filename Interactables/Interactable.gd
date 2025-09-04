extends Node
class_name Interactable

@export var unique_id:String = ""
@export var interact_area:Area3D
@export var indicator_place:Node3D
@export var interact_sound: AudioStream = null
@export var interact_text: String = "Interact"
@export var oneshot:bool = false
@export var audio_player_3d: AudioStreamPlayer3D

var used:bool = false
var player:Player = null
var indicator:Indicator = null
var label:Label3D = null

func _ready() -> void:
	_on_creation()

func _on_creation() -> void:
	#Set to scan GameCharacters
	interact_area.set_collision_mask_value(4,true)
	if audio_player_3d: audio_player_3d.stream = interact_sound
	interact_text = "(" + get_input_string("Interact") + ") " + interact_text
	#TODO sub to signal when keybinds changed
	interact_area.connect("body_entered", Callable(self, "_on_Area3D_body_entered"))
	interact_area.connect("body_exited", Callable(self, "_on_Area3D_body_exited"))

func _on_Area3D_body_entered(body: Node) -> void:
	if body is Player:
		player = body
		var entered_player:Player = body as Player
		entered_player.interact_handler.add_interactable(self)

func _on_Area3D_body_exited(body: Node) -> void:
	if body is Player:
		var exited_player:Player = body as Player
		exited_player.interact_handler.remove_interactable(self)

func show_indicator(ind:Indicator, lab:Label3D) -> void:
	indicator = ind
	label = lab

	lab.text = self.interact_text
	lab.global_position = self.indicator_place.global_position
	ind.global_position = self.indicator_place.global_position + Vector3(0,0.1,0)
	lab.show()
	ind.show_indicator()

func hide_indicator(instant:bool = false) -> void:
	if indicator == null: return
	if label == null: return
	
	label.hide()
	indicator.hide_indicator(instant)
	
	indicator = null
	label = null

#Override this
func interact() -> void:
	pass
	
func handle_oneshot() -> void:
	interact_area.monitoring = false
	
func get_input_string(action_name: String) -> String:
	var events:Array[InputEvent] = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var event:InputEvent = events[0]
		var button_name: String = OS.get_keycode_string( event.physical_keycode )
		return button_name

	return "Unknown"

#Override this
func save_to_data(save_data:Dictionary) -> void:
	print(save_data)

#Override this
func load_from_data(save_data:Dictionary) -> void:
	print(save_data)
