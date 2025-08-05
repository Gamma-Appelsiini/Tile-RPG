extends Node
class_name Interactable

@export var interact_area:Area3D
@export var indicator_place:Node3D
@export var interact_sound: AudioStream = null
@export var interact_text: String = "Interact"
@export var oneshot:bool = false
@export var audio_player_3d: AudioStreamPlayer3D

var used:bool = false
var player:Player = null

func _ready() -> void:
	#interact_area.collision_mask = 4
	interact_text = "(" + get_input_string("Interact") + ")" + interact_text
	#TODO sub to signal when keybinds changed
	interact_area.connect("body_entered", Callable(self, "_on_Area3D_body_entered"))
	interact_area.connect("body_exited", Callable(self, "_on_Area3D_body_exited"))

func _on_Area3D_body_entered(body: Node) -> void:
	if body is Player:
		var entered_player:Player = body as Player
		entered_player.interact_handler.add_interactable(self)

func _on_Area3D_body_exited(body: Node) -> void:
	if body is Player:
		var exited_player:Player = body as Player
		exited_player.interact_handler.remove_interactable(self)

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
