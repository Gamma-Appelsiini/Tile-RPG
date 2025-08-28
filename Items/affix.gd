class_name Affix

var affix_name:String = "Default affix name"
var affix_text:String = "Default affix text"

var type_increase:int = -1
var increase_amount:int = 0
var affix_generator:Callable
var generator_key:String = ""

func apply_to_character(game_char:GameCharacter) -> void:
	#Defence stat increases armor base armor which is applied when equipped
	if type_increase in Stats.Defence.values(): return
	game_char.stat_handler.update_stat(type_increase,increase_amount)

func remove_from_character(game_char:GameCharacter) -> void:
	#Defence stat increases armor base armor which is applied when equipped
	if type_increase in Stats.Defence.values(): return
	game_char.stat_handler.update_stat(type_increase,increase_amount * -1)

func get_save_data() -> Dictionary:
	var data:Dictionary = {
		"affix_name": affix_name,
		"affix_text": affix_text,
		"type_increase": type_increase,
		"increase_amount": increase_amount,
		"generator_key": generator_key
	}

	return data

func load_from_data(data:Dictionary) -> void:
	affix_name = data["affix_name"]
	affix_text = data["affix_text"]
	type_increase = data["type_increase"]
	increase_amount = data["increase_amount"]
	generator_key = data["generator_key"]
