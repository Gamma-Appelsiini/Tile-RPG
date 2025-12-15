extends PanelContainer
class_name XpPanel

@export var progress_bar: ProgressBar = null
@export var texture_rect: TextureRect = null
@export var green_bar: ProgressBar = null

const FULL_BAR_TIME: float = 1.25

# Queue holds dictionaries: { "cur": int, "max": int }
var queue: Array[Dictionary] = []
var is_animating: bool = false
var stat_handler:StatHandler = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Journal"):
		GlobalSignals.player.stat_handler.add_xp(25)

func set_stat_handler(sh: StatHandler) -> void:
	var start_max:int = sh.get_stat_amount(Stats.CharStat.MAX_XP)
	var start_cur:int = sh.get_stat_amount(Stats.CharStat.CURRENT_XP)
	_update_visuals_immediate(start_cur, start_max)
	
	sh.xp_changed.connect(_on_xp_changed_signal)
	stat_handler = sh

func _on_xp_changed_signal(cur_xp: int, max_xp: int) -> void:
	queue.push_back({ "cur": cur_xp, "max": max_xp })
	_process_queue()

func _process_queue() -> void:
	if is_animating or queue.is_empty():
		return

	is_animating = true
	
	var target:Dictionary[String, int] = queue.pop_front()
	var target_cur:int = target["cur"]
	var target_max:int = target["max"]
	
	if target_max > progress_bar.max_value:
		await _sequence_level_up(target_max)
	
	await _sequence_gain(target_cur, target_max)
	
	is_animating = false
	_process_queue()


func _sequence_level_up(new_max: int) -> void:
	await _animate_single_bar(green_bar, int(progress_bar.max_value))
	await _animate_single_bar(progress_bar, int(progress_bar.max_value))
	
	progress_bar.max_value = new_max
	progress_bar.value = 0
	green_bar.max_value = new_max
	green_bar.value = 0
	
	await get_tree().create_timer(0.05).timeout
	stat_handler.leveled_up.emit()

func _sequence_gain(target_cur: int, target_max: int) -> void:
	if texture_rect:
		texture_rect.tooltip_text = str(target_cur) + " / " + str(target_max)

	await _animate_single_bar(green_bar, target_cur)
	await _animate_single_bar(progress_bar, target_cur)

func _animate_single_bar(bar: ProgressBar, target_val: int) -> void:
	if bar.value == target_val:
		return

	var duration:float = _get_tween_time(bar.value, target_val, bar.max_value)
	
	var tween:Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(bar, "value", target_val, duration)
	
	await tween.finished

func _update_visuals_immediate(cur: int, max_val: int) -> void:
	progress_bar.max_value = max_val
	progress_bar.value = cur
	green_bar.max_value = max_val
	green_bar.value = cur

func _get_tween_time(start_val: float, end_val: float, max_val: float) -> float:
	var diff:float = abs(end_val - start_val)
	if max_val == 0: return 0.1
	var time:float = FULL_BAR_TIME * (diff / float(max_val))
	return clamp(time, 0.1, 1.0)
