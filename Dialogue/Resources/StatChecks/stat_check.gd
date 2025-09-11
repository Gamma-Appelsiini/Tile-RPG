extends Resource
class_name StatCheck

@export var stat_type:Stats.MainStat
@export var pass_amount:int
@export var min_amount:int

@export_multiline var line_text:String
@export_multiline var fail_text:String
@export_multiline var pass_text:String

@export var pass_func:Callable
@export var pass_dialogue:DialogueResource
@export var fail_func:Callable
@export var fail_dialogue:DialogueResource

func _get_pass_percentage(stat_amount:int) -> float:
	var percentage:float = 0.0
	
	if min_amount > stat_amount: return percentage
	if stat_amount >= pass_amount: return 1.0
	
	var t:float = float(stat_amount - min_amount) / float(pass_amount - min_amount)
	percentage = 0.1 + t * 0.9
	
	return percentage

func attempt_check(stat_amount:int) -> bool:
	var percent:float = randf_range(0.0,1.0)
	var pass_percent:float = _get_pass_percentage(stat_amount)
	
	if percent > pass_percent: return false
	else: return true
