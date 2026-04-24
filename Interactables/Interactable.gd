extends Node3D
class_name Interactable

signal interact_complete

@export var unique_id:String = ""
@export var interact_area:Area3D
@export var indicator_place:Node3D
@export var interact_sound: AudioStream = null
@export var interact_text: String = "Interact"
@export var oneshot:bool = false
@export var face_interactable:bool = false
@export var block_tiles:bool = false
@export var interact_animation:CharacterModelHandler.CharAnimation = CharacterModelHandler.CharAnimation.NULL
@export var interact_position:Node3D = null

const INTERACT_DELAYS:Dictionary[CharacterModelHandler.CharAnimation, float] = {
	CharacterModelHandler.CharAnimation.INTERACT: 0.3,
	CharacterModelHandler.CharAnimation.PICKUP: 0.85,
}

var used:bool = false
var player:Player = null
var indicator:Indicator = null
var prompt:InteractPrompt = null

func _ready() -> void:
	_on_creation()

func get_interact_text() -> String:
	return interact_text

func _on_creation() -> void:
	#Set to scan GameCharacters
	interact_area.set_collision_mask_value(4,true)
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

func get_interact_pos() -> Node3D:
	return indicator_place

#Override this
func interact() -> void:
	interact_complete.emit()
	
func handle_oneshot() -> void:
	if !oneshot: return
	interact_area.monitoring = false

#Override this
func save_to_data(save_data:Dictionary) -> void:
	pass
	#print_debug(save_data)

#Override this
func load_from_data(save_data:Dictionary) -> void:
	pass
	#print_debug(save_data)
