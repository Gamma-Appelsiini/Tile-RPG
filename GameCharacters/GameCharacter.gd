extends CharacterBody3D
class_name GameCharacter

enum CharacterState {OUT_OF_COMBAT, IN_COMBAT, FROZEN, STUNNED, DEAD, RUNNING, INTERACTING}

signal move_complete
signal rotation_complete
signal died(char:GameCharacter)
signal dodged
signal blocked
signal got_hit
signal start_turn
signal end_turn
signal moved_to_tile(tile:Tile)
signal ready_to_move
signal draw_weapon
signal hide_weapon
signal character_mouse_over
signal character_mouse_left

@export var unique_id:String = ""
@export var character_power:int = 0
@export var display_name:String = "Default Name"
@export var picture:Texture2D = null
@export var stat_resource:StatResource = null
@export var follow_hander:FollowHandler = null
@export var heigth_node:Node3D = null
@export var infobar:CharacterInfoBar = null
@export var ai_handler:AIHandler = null
@export var char_model_handler:CharacterModelHandler = null
@export var equipment_handler:EquipmentHandler = null

var move_tween:Tween = null
var stat_handler:StatHandler = null

var status_handler:StatusHandler = null
var character_state:CharacterState = CharacterState.OUT_OF_COMBAT

#TODO mouseover fails from behind transparent walls
func _connect_mouse_over_outlining() -> void:
	self.mouse_entered.connect(func():
		character_mouse_over.emit()
	)
	
	self.mouse_exited.connect(func():
		character_mouse_left.emit()
	)

func change_state(new_state:CharacterState) -> void:
	var prev_state:CharacterState = character_state
	self.character_state = new_state
	
	if char_model_handler == null: return
	
	if new_state == CharacterState.OUT_OF_COMBAT: _enter_out_of_combat_state(prev_state)
	elif new_state == CharacterState.IN_COMBAT: _enter_combat_state(prev_state)
	elif new_state == CharacterState.RUNNING: char_model_handler.play_animation(CharacterModelHandler.CharAnimation.RUN, false)
	elif new_state == CharacterState.DEAD: _enter_dead_state()

func enter_interact_state(interact_animation:CharacterModelHandler.CharAnimation) -> void:
	set_process_input(false)
	
	char_model_handler.play_animation(interact_animation, false)
	await char_model_handler.animation_player.animation_finished
	
	change_state(CharacterState.OUT_OF_COMBAT)
	
func _leave_interact_state() -> void:
	set_physics_process(true)
	set_process_input(true)

func _enter_dead_state() -> void:
	GlobalSignals.combat_start.disconnect(change_state.bind(CharacterState.IN_COMBAT))
	GlobalSignals.combat_end.disconnect(change_state.bind(CharacterState.OUT_OF_COMBAT))
	char_model_handler.die()

func _enter_out_of_combat_state(prev_state:CharacterState) -> void:
	const WEAPON_HIDE_STATES:Array[CharacterState] = [CharacterState.IN_COMBAT, CharacterState.STUNNED, CharacterState.FROZEN]
	if WEAPON_HIDE_STATES.has(prev_state):
		char_model_handler.play_animation(CharacterModelHandler.CharAnimation.DRAW_WEAPON,true, true)
		await get_tree().create_timer(char_model_handler.DELAYS[CharacterModelHandler.CharAnimation.DRAW_WEAPON]).timeout
		hide_weapon.emit()
	else:
		char_model_handler.play_idle_animation()

func _enter_combat_state(prev_state:CharacterState) -> void:
	const WEAPON_DRAW_STATES:Array[CharacterState] = [CharacterState.OUT_OF_COMBAT, CharacterState.RUNNING, CharacterState.INTERACTING]
	if WEAPON_DRAW_STATES.has(prev_state):
		char_model_handler.play_animation(CharacterModelHandler.CharAnimation.DRAW_WEAPON, false)
		await get_tree().create_timer(char_model_handler.DELAYS[CharacterModelHandler.CharAnimation.DRAW_WEAPON]).timeout
		draw_weapon.emit()
		await char_model_handler.animation_player.animation_finished
		ready_to_move.emit()
	else:
		char_model_handler.play_idle_animation()

func _set_infobar() -> void:
	if !infobar: return
	infobar.set_game_character(self)

func _init() -> void:
	_add_handlers()
	_connect_mouse_over_outlining()
	_connect_state_signals()

func _add_handlers() -> void:
	#Stats
	stat_handler = StatHandler.new()
	if stat_resource: stat_handler.set_stats_from_resource(stat_resource)
	stat_handler.owner_died.connect(_die)
	start_turn.connect(stat_handler.on_turn_start)
	
	#Status
	status_handler = StatusHandler.new()
	add_child(status_handler)
	
	#Equipment
	if !equipment_handler:
		equipment_handler = EquipmentHandler.new()

func _die() -> void:
	#TODO
	print_debug("Character ", self.display_name, " died.")
	change_state(CharacterState.DEAD)
	died.emit(self)

func _connect_state_signals() -> void:
	GlobalSignals.combat_start.connect(change_state.bind(CharacterState.IN_COMBAT))
	GlobalSignals.combat_end.connect(change_state.bind(CharacterState.OUT_OF_COMBAT))

func _ready() -> void:
	if unique_id == "": print_debug("ID NOT SET: ", self)
	_set_infobar()
	
func load_from_data(save_data:Dictionary) -> void:
	var characters:Dictionary = save_data["game_characters"]
	if !characters.has(unique_id):
		print_debug(unique_id, " not in save data")
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
	_rotate(point)
	
	char_model_handler.play_animation(CharacterModelHandler.CharAnimation.RUN, false)
	
	var distance:float = self.global_position.distance_to(point)
	var move_time:float = 0.4 * distance
	move_tween = create_tween()
	if start: move_tween.set_ease(Tween.EASE_OUT)
	elif end: move_tween.set_ease(Tween.EASE_IN)
	elif start and end: move_tween.set_ease(Tween.EASE_IN_OUT)
	
	move_tween.tween_property(self, "global_position", point, move_time)
	
	await move_tween.finished
	if end: char_model_handler.play_idle_animation()
	move_complete.emit()

func rotate_towards_point(point: Vector3) -> void:
	var tween:Tween = _rotate(point)
	await tween.finished
	rotation_complete.emit()

func _rotate(point: Vector3) -> Tween:
	var dir := global_position.direction_to(point)
	var target_yaw := atan2(dir.x, dir.z)
	var current_yaw := char_model_handler.global_rotation.y
	var angle_diff := angle_difference(current_yaw, target_yaw)
	var final_yaw := current_yaw + angle_diff

	const FULL_ROTATION_TIME: float = 0.4
	var rotation_time: float = clampf(FULL_ROTATION_TIME * (abs(angle_diff) / PI), 0.1, FULL_ROTATION_TIME)

	var tween := create_tween()
	tween.tween_property(char_model_handler, "global_rotation:y", final_yaw, rotation_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
