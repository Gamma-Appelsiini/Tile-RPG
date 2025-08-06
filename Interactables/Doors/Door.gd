extends Interactable
class_name Door

@export var side_1:Node3D
@export var side_2:Node3D
@export var pivot:Node3D

const OPEN_TIME:float = 0.55
const ROTATION_AMOUNT:float = -1.5708
var rotation:float = 0
var return_rotation:float = 0
var locked:bool = false
var interaction_enabled:bool = true
var closest_interact:Node3D = null

func interact() -> void:
	if !interaction_enabled: return
	_handle_locked()
	if locked: return
	interaction_enabled = false
	
	if used: rotation = return_rotation
	else:
		var distance_1:float = player.global_transform.origin.distance_to(side_1.global_transform.origin)
		var distance_2:float = player.global_transform.origin.distance_to(side_2.global_transform.origin)
		rotation = ROTATION_AMOUNT
		if distance_2 < distance_1:
			rotation *= -1
		return_rotation = rotation * -1
	
	used = !used
	hide_indicator()
	interact_text = "Open"
	if used: interact_text = "Close"
	
	var tween:Tween = create_tween()
	tween.tween_property(pivot,"rotation",pivot.rotation +Vector3(0, rotation, 0), OPEN_TIME).set_ease(Tween.EASE_OUT)
	audio_player_3d.play()
	
	await tween.finished
	interaction_enabled = true
	
#Overrided due to doors having 2 interact points
func show_indicator(ind:Indicator, lab:Label3D) -> void:
	indicator = ind
	label = lab
	
	var distance_1:float = player.global_transform.origin.distance_to(side_1.global_transform.origin)
	var distance_2:float = player.global_transform.origin.distance_to(side_2.global_transform.origin)
	rotation = ROTATION_AMOUNT
	
	if used: rotation = return_rotation
	else:
		closest_interact = side_1
		if distance_2 < distance_1:
			closest_interact = side_2
			rotation *= -1
		return_rotation = rotation * -1
	
	lab.text = self.interact_text
	lab.global_position = closest_interact.global_position
	ind.global_position = closest_interact.global_position + Vector3(0,0.1,0)
	lab.show()
	ind.show_indicator()

	
#TODO add locked/key functionality
func _handle_locked() -> void:
	pass
