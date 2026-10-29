extends Resource
class_name ShopResource

@export_category("Shop Stats")
@export var shop_name:String = "Name"
@export var shop_level:int = 1
@export var shop_portrait:Texture2D = null

@export_category("Flavor Texts")
@export_multiline() var FLAVOR_TEXT_BUY:Array[String] = ["Sold. For a good price.", "Good choice.", "I would have bought the same one myself."]
@export_multiline() var FLAVOR_TEXT_SELL:Array[String] = ["I'll take it off you.", "Where did you find this one?", "A common item."]
@export_multiline() var FLAVOR_TEXT_GOODBYE:Array[String] = ["Come back again.", "You're my best customer.", "Great deals here again tomorrow."]
@export_multiline() var FLAVOR_TEXT_WELCOME:Array[String] = ["Welcome to my shop.", "Good deals can be found here.", "Let me lighten your purse."]
@export_multiline() var FLAVOR_TEXT_NOT_ENOUGH_BUX:Array[String] = ["It seems you are too poor.", "Come back with more Bux.", "You need fatter pockets."]

var last_open_lvl:int = 1

func save_to_data(items_in_shop:Dictionary[InventoryItem, InventorySquare]) -> void:
	var save_data:Dictionary = GlobalSignals.GAME_SAVE_DATA
	var item_save_data:Dictionary = {}
	var shop_save_data:Dictionary = {}
	
	for inv_item:InventoryItem in items_in_shop.keys():
		item_save_data[Vector2i(items_in_shop[inv_item].pos_x, items_in_shop[inv_item].pos_y)] = inv_item.item.save_to_data()
	
	shop_save_data["last_open_lvl"] = GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
	shop_save_data["item_save_data"] = item_save_data
	
	save_data["shops"][shop_name] = shop_save_data

func load_from_data() -> bool:
	var save_data:Dictionary = GlobalSignals.GAME_SAVE_DATA
	if !save_data["shops"].has(shop_name):
		print_debug("Shop not in save data")
		return false
	
	print_debug("Shop was in save data")
	var shop_save_data:Dictionary = save_data["shops"][shop_name]
	var item_save_data:Dictionary = shop_save_data["item_save_data"]
	last_open_lvl = shop_save_data["last_open_lvl"]
	
	for pos:Vector2i in item_save_data.keys():
		var script: Script = load(item_save_data[pos]["item_type"])
		var loaded_item:Item = script.new()
		loaded_item.load_from_data(item_save_data[pos])
		
		#Place on shop
		GlobalSignals.ui_handler.inventory_panel.add_item_to_specific_spot_on_shop(loaded_item, pos)
	
	return true
