extends Interactable
class_name Shop

@export var shop_name:String = "Shop Name"
@export var shop_portrait:Texture2D = null
@export var equipment_displayer:EquipmentDisplayer = null

var shop_save_data:Dictionary = {
	"currency_amount": 0,
	"last_open_lvl": -1,
	"items": [],
	"prices": [],
}

var shop_window:ShopWindow = null
var last_open_lvl:int = -1
var player_inventory:Inventory = null
var ui_handler:UIHandler = null

func show_shopkeeper_talking(new_text:String) -> void:
	#TODO
	pass

#Overrided
func interact() -> void:
	_set_shop_window_ref()
	shop_window.equipment_displayer = equipment_displayer
	_generate_new_items()
	
	shop_window.open_shop(self)
	
	if !ui_handler.inventory.visible:
		ui_handler.toggle_inv()

func _set_shop_window_ref() -> void:
	var UI := get_tree().get_nodes_in_group("UI")
	if UI[0] is UIHandler:
		ui_handler = UI[0] as UIHandler
		shop_window = ui_handler.shop_window
		player_inventory = ui_handler.inventory

func _generate_new_items() -> void:
	var player_lvl:int = GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
	
	if player_lvl > last_open_lvl:
		shop_window.fill_items()

	last_open_lvl = player_lvl

#Overrided
func save_to_data(save_data:Dictionary) -> void:
	if unique_id == "":
		print_debug("ERROR NO UNIQUE ID FOR SHOP")
		return
	
	_set_shop_window_ref()
	var item_array:Array[Dictionary] = []
	var price_array:Array[int] = []
	
	shop_save_data = {
		"currency_amount": player_inventory.player_currency,
		"items": item_array,
		"prices": price_array,
	}
	for item_panel:ShopItemPanel in shop_window.item_panels:
		if item_panel.inventory_slot.item_in_slot == null: continue
		item_array.push_back(item_panel.inventory_slot.item_in_slot.save_to_data())
		price_array.push_back(item_panel.item_price)
		
	shop_save_data["last_open_lvl"] = last_open_lvl
	save_data["shops"][unique_id] = shop_save_data

#Overrided
func load_from_data(save_data:Dictionary) -> void:
	if unique_id == "":
		print_debug("ERROR NO UNIQUE ID FOR SHOP")
		return
	if !save_data["shops"].has(unique_id): return
	
	_set_shop_window_ref()
	shop_window.reset_shop()
	
	var shop_data:Dictionary = save_data["shops"][unique_id]
	
	last_open_lvl = shop_data["last_open_lvl"]
	player_inventory.player_currency = shop_data["currency_amount"]
	var item_array:Array[Dictionary] = shop_data["items"]
	var price_array:Array[int] = shop_data["prices"]
	
	for i:int in len(item_array):
		var script: Script = load(item_array[i]["item_type"])
		var loaded_item:Item = script.new()

		loaded_item.load_from_data(item_array[i])
		shop_window.item_panels[i].set_item(loaded_item, price_array[i])
		
