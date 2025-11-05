extends CharacterBody3D
class_name GameCharacter

signal move_complete
signal rotation_complete
signal died(char:GameCharacter)
signal dodged
signal blocked
signal got_hit
signal start_turn
signal end_turn
signal moved_to_tile(tile:Tile)

@export var unique_id:String = ""
@export var display_name:String = "Default Name"
@export var picture:Texture2D = null
@export var stat_resource:StatResource = null
@export var visual_mesh:MeshInstance3D
@export var follow_hander:FollowHandler = null

var move_tween:Tween = null

var stat_handler:StatHandler = null
var equipment_handler:EquipmentHandler = null
@export var ai_handler:AIHandler = null

func _init() -> void:
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)
	stat_handler.owner_died.connect(_die)
	start_turn.connect(stat_handler.on_turn_start)
	
	
	equipment_handler = EquipmentHandler.new()
	add_child(equipment_handler)
	equipment_handler.equipment_owner = self

func _die() -> void:
	#TODO
	print("ASODIFJNSDIFJSDIFHSODIFHSDFIHSODIFH")
	print("Character ", self.display_name, " died.")
	died.emit(self)

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

func stop_moving() -> void:
	if move_tween != null: move_tween.stop()

func move_to_point(point: Vector3, start:bool = false, end:bool = false) -> void:
	set_physics_process(false)
	_rotate(point)
	
	var distance:float = self.global_position.distance_to(point)
	var move_time:float = 0.4 * distance
	move_tween = create_tween()
	if start: move_tween.set_ease(Tween.EASE_OUT)
	elif end: move_tween.set_ease(Tween.EASE_IN)
	elif start and end: move_tween.set_ease(Tween.EASE_IN_OUT)
	
	move_tween.tween_property(self, "global_position", point, move_time)
	
	await move_tween.finished
	move_complete.emit()
	
	if end: set_physics_process(true)

func rotate_towards_point(point: Vector3) -> void:
	set_physics_process(false)

	var tween:Tween = _rotate(point)
	await tween.finished
	
	set_physics_process(true)
	rotation_complete.emit()

func _rotate(point: Vector3) -> Tween:
	var dir: Vector3 = (point - global_position).normalized()
	var target_yaw: float = atan2(dir.x, dir.z)
	var current_yaw: float = visual_mesh.rotation.y
	var delta: float = fmod((target_yaw - current_yaw) + PI, TAU) - PI
	var final_yaw: float = lerp_angle(current_yaw, target_yaw, 1.0)

	const FULL_ROTATION_TIME: float = 0.8
	var angle_diff: float = abs(delta)
	var rotation_time:float = clampf(FULL_ROTATION_TIME * (angle_diff / TAU), 0.1, FULL_ROTATION_TIME)
	
	var tween := create_tween()
	tween.tween_property(visual_mesh, "rotation:y", final_yaw, rotation_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
