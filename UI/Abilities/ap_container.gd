extends HBoxContainer
class_name ApContainer

var ap_balls:Array[ApBall] = []

func _ready() -> void:
	ap_balls = get_children() as Array[ApBall]

func use_ap(amount:int) -> void:
	var spot:int = len(ap_balls) -1
	while ap_balls[spot].empty:
		spot -= 1
	
	while amount > 0:
		ap_balls[spot].hide_ap()
		amount -= 1
		spot -= 1
	
func add_ap(amount:int) -> void:
	for ball:ApBall in ap_balls:
		if amount == 0: break
		if ball.empty:
			ball.show_ap()
			amount -= 1
