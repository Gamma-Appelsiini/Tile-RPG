extends Interactable
class_name SaveInteractable

const DIALOGUE_BUBBLE := preload("uid://b7q77u7wvwvi3")

@export var saved_sound:AudioStream = null
@export var moving_mesh: MeshInstance3D = null
@onready var dialogue_place: Node3D = $DialoguePlace

#Overrided
func interact() -> void:
	GlobalSignals.save_game.emit()
	await _animate_saving()
	

func _animate_saving() -> void:
	moving_mesh.show()
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(moving_mesh, "position", moving_mesh.position + Vector3(0,1.25,0), 1.5)
	
	await tween.finished
	interact_complete.emit()
	
	GlobalSignals.play_audio.emit(saved_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, moving_mesh.global_position)
	_show_saved_message()
	
	await get_tree().create_timer(0.25).timeout
	
	var tween2:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween2.tween_property(moving_mesh, "position", moving_mesh.position - Vector3(0,1.25,0), 1.5)
	
	await tween2.finished
	moving_mesh.hide()
	

func _show_saved_message():
	var new_dialogue_bubble:DialogueBubble = DIALOGUE_BUBBLE.instantiate()
	add_child(new_dialogue_bubble)
	new_dialogue_bubble.set_params("",null, dialogue_place, get_viewport().get_camera_3d())
	new_dialogue_bubble.set_simple_dialogue("Game Saved")
