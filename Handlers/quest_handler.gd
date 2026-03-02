extends Resource
class_name QuestHandler

var quest_handler_save_data:Dictionary = {
	"player_currency": 0,
}

func load_from_data(data:Dictionary) -> void:
	var save_data:Dictionary = data["quest_handler"]
	if save_data == {}: return

func save_to_data(data:Dictionary) -> void:
	var currency_amount:int = GlobalSignals.ui_handler.inventory.player_currency
	quest_handler_save_data["player_currency"] = currency_amount
	
	data["quest_handler"] = quest_handler_save_data
