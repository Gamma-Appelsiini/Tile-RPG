class_name Affix

var affix_name:String = "Default affix name"
var affix_text:String = "Default affix text"

var type_increase:int = -1
var increase_amount:int = 0
var affix_generator:Callable

func apply_to_character(game_char:GameCharacter) -> void:
	game_char.stat_handler.update_stat(type_increase,increase_amount)

func remove_from_character(game_char:GameCharacter) -> void:
	game_char.stat_handler.update_stat(type_increase,increase_amount * -1)

func get_save_data() -> Dictionary:
	var data:Dictionary = {
		"affix_name": affix_name,
		"affix_text": affix_text,
		"type_increase": type_increase,
		"increase_amount": increase_amount,
		"affix_generator": affix_generator
	}
	return data
	
func load_from_data(data:Dictionary) -> void:
	affix_name = data["affix_name"]
	affix_text = data["affix_text"]
	type_increase = data["type_increase"]
	increase_amount = data["increase_amount"]
	affix_generator = data["affix_generator"]
