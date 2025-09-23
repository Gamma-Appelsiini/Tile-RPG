extends CharacterBody3D
class_name GameCharacter

signal move_complete
signal rotation_complete

@export var unique_id:String = ""
@export var display_name:String = "Default Name"
@export var picture:Texture2D = null
@export var stat_resource:StatResource = null
@export var visual_mesh:MeshInstance3D

const EASE_TYPE: Tween.EaseType = Tween.EASE_IN_OUT
const TRANS_TYPE: Tween.TransitionType = Tween.TRANS_SINE

var stat_handler:StatHandler = null
var equipment_handler:EquipmentHandler = null

func _init() -> void:
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)
	
	equipment_handler = EquipmentHandler.new()
	equipment_handler.equipment_owner = self

func _ready() -> void:
	if unique_id == "": print("ID NOT SET: ", self)

func load_from_data(save_data:Dictionary) -> void:
	var characters:Dictionary = save_data["game_characters"]
	if !characters.has(unique_id):
		print(unique_id, " not in save data")
		return
		
	var gpos:Vector3 = save_data["game_characters"][unique_id]["global_position"]
	stat_handler.load_from_data(save_data,unique_id)
	if is_inside_tree(): self.global_position = gpos

func save_to_data(save_data:Dictionary) -> void:
	if !save_data["game_characters"].has(unique_id):
		save_data["game_characters"][unique_id] = {}
	
	#TODO add other things characters need saving	
	save_data["game_characters"][unique_id]["global_position"] = self.global_position
	stat_handler.save_to_data(save_data,self.unique_id)

func move_to_point(point: Vector3, start:bool = false, end:bool = false) -> void:
	set_physics_process(false)
	
	var distance:float = self.global_position.distance_to(point)
	var move_time:float = 0.6 * distance
	var tween := create_tween()
	if start: tween.set_ease(Tween.EASE_OUT)
	elif end: tween.set_ease(Tween.EASE_IN)
	elif start and end: tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "global_position", point, move_time)
	
	await tween.finished
	move_complete.emit()
	set_physics_process(true)

func rotate_towards_point(point: Vector3) -> void:
	set_physics_process(false)

	const ROTATION_TIME: float = 0.4
	var dir: Vector3 = (point - global_position).normalized()
	var target_yaw: float = atan2(dir.x, dir.z)
	var current_yaw: float = visual_mesh.rotation.y
	var delta: float = fmod((target_yaw - current_yaw) + PI, TAU) - PI
	var final_yaw: float = current_yaw + delta

	var tween := create_tween()
	tween.tween_property(visual_mesh, "rotation:y", final_yaw, ROTATION_TIME).set_trans(TRANS_TYPE).set_ease(EASE_TYPE)

	await tween.finished
	rotation_complete.emit()
	set_physics_process(true)
