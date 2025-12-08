extends PanelContainer
class_name XpPanel

@export var progress_bar: ProgressBar = null
@export var texture_rect: TextureRect = null

const FULL_BAR_TIME:float = 1.0

var queue:Array[int] = []
var tween:Tween = null

func set_stat_handler(sh:StatHandler) -> void:
	sh.stats_changed.connect(_set_xp.bind(sh))
	_set_xp(sh)
	
func _set_xp(sh:StatHandler) -> void:
	print(1)
	var cur_xp:int = sh.get_stat_amount(Stats.CharStat.CURRENT_XP)
	var max_xp:int = sh.get_stat_amount(Stats.CharStat.MAX_XP)
	
	if tween != null:
		queue.push_back(cur_xp)
		queue.push_back(max_xp)
		return
	
	_animate_bar(cur_xp, max_xp)
	
func _animate_bar(cur_xp:int, max_xp:int):
	if progress_bar.value == cur_xp and progress_bar.max_value == max_xp:
		return
	
	var tween_time:float = FULL_BAR_TIME * ( float(max_xp) / float(cur_xp))
	if tween_time == INF: tween_time = .1

	texture_rect.tooltip_text = str(cur_xp) + " / " + str(max_xp)
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(progress_bar, "max_value", max_xp, tween_time)
	tween.tween_property(progress_bar, "value", cur_xp, tween_time)
	
	await tween.finished
	tween = null
	
	if !queue.is_empty():
		var next_cur:int = queue.pop_front()
		var next_max:int = queue.pop_front()
		_animate_bar(next_cur,next_max)
