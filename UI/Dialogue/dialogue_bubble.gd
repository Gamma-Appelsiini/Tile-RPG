extends Control
class_name DialogueBubble

signal dialogue_finished

@onready var dialogue_label: Label = %DialogueLabel
@onready var picture_rect: TextureRect = %PictureRect
@onready var name_label: Label = %NameLabel
@onready var panel_container: PanelContainer = %PanelContainer
@onready var nine_patch_rect: NinePatchRect = %NinePatchRect
@onready var continue_rect: TextureRect = %ContinueRect

const ARROW_GREEN:Texture2D = preload("res://Tile-RPG/Images/UI/arrow_green.png")
const CROSS:Texture2D = preload("res://Tile-RPG/Images/UI/cross.png")
const DISSOLVE_TIME:float = 0.3
const TIME_PER_LETTER:float = 0.02

var dissolve_material:ShaderMaterial = null
var dialogue_resource:DialogueResource = null

var position_node:Node3D
var game_camera:Camera3D

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	self.visible = false
	continue_rect.visible = false
	
	dissolve_material = picture_rect.material
	dissolve_material.set_shader_parameter("dissolve_value", 0.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") or event.is_action_pressed("Jump"):
		set_next_text()

func set_params(dialogue_name,picture:Texture2D, dialogue_pos_node:Node3D, camera:Camera3D) -> void:
	game_camera = camera
	position_node = dialogue_pos_node
	name_label.text = dialogue_name
	picture_rect.texture = picture
	continue_rect.texture = ARROW_GREEN

func _change_continue_pic() -> void:
	continue_rect.texture = CROSS

func _process(_delta: float) -> void:
	var screen_position = game_camera.unproject_position(position_node.global_transform.origin)
	self.global_position = screen_position

func show_dialogue(new_dialogue:DialogueResource) -> void:
	set_process(true)
	set_process_input(true)
	self.visible = true
	new_dialogue.last_text.connect(_change_continue_pic)
	
	dialogue_resource = new_dialogue
	dialogue_resource.current_spot = 0
	_change_label_text(name_label, name_label.text,DISSOLVE_TIME)
	
	var tween:Tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolve_value", 1.0, DISSOLVE_TIME)
	await tween.finished
	
	set_next_text()
	
func set_next_text() -> void:
	var next_text:String = dialogue_resource.get_next_dialogue()
	if next_text == "":
		_close_dialogue()
		return
	
	_change_label_text(dialogue_label, next_text)
	
func _close_dialogue() -> void:
	set_process_input(false)
	_change_label_text(dialogue_label, "",DISSOLVE_TIME)
	_change_label_text(name_label, "",DISSOLVE_TIME)
	
	var tween:Tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolve_value", 0.0, DISSOLVE_TIME)
	await tween.finished
	
	self.visible = false
	set_process(false)
	dialogue_resource.last_text.disconnect(_change_continue_pic)
	dialogue_finished.emit()
	self.queue_free()

func _change_label_text(label:Label,new_text:String, time_override:float = 0):
	set_process_input(false)
	continue_rect.visible = false

	var change_time = new_text.length() * TIME_PER_LETTER
	if time_override != 0: change_time = time_override
	
	label.text = ""
	var tween:Tween = create_tween().set_parallel(true)
	tween.tween_property(label,"text",new_text, change_time).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	set_process_input(true)
	continue_rect.visible = true
