extends HBoxContainer
class_name ApContainer

var ap_balls:Array[ApBall] = []
var stat_handler:StatHandler = null

func _ready() -> void:
	for ball:ApBall in get_children() :
		ap_balls.push_back(ball)
	
func set_player(player:Player) -> void:
	stat_handler = player.stat_handler
	stat_handler.stats_changed.connect(_set_ap)

func _set_ap() -> void:
	for ball:ApBall in ap_balls:
		ball.hide_ap()
		
	var ap_amount:int = stat_handler.resources[Stats.ResourceStat.CURRENT_AP]
	for ball:ApBall in ap_balls:
		if ap_amount == 0: break
		ball.show_ap()
		ap_amount -= 1
