extends Interactable
class_name Shop

const DIALOGUE_BUBBLE := preload("uid://b7q77u7wvwvi3")

@export var shop_name:String = "Shop Name"
@export var shop_portrait:Texture2D = null
@export var equipment_displayer:EquipmentDisplayer = null
@export var dialogue_place:Node3D = null
@export var enter_area:Area3D = null

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
var dialogue_on_cd:bool = false

#Overrided
func _ready() -> void:
	_on_creation()
	if enter_area:
		enter_area.connect("body_entered", Callable(self, "_on_enter_area_entered"))

func _on_enter_area_entered(body:Node) -> void:
	if body is not Player: return
	
	_show_welcome_dialogue()
	enter_area.set_deferred("monitoring", false)

func show_shopkeeper_talking(new_text:String) -> void:
	if dialogue_on_cd: return
	dialogue_on_cd = true
	
	var new_dialogue_bubble:DialogueBubble = DIALOGUE_BUBBLE.instantiate()
	add_child(new_dialogue_bubble)
	new_dialogue_bubble.set_params(shop_name,shop_portrait, dialogue_place, get_viewport().get_camera_3d())
	new_dialogue_bubble.set_simple_dialogue(new_text)

	await new_dialogue_bubble.dialogue_finished
	dialogue_on_cd = false

func _show_welcome_dialogue() -> void:
	show_shopkeeper_talking(shop_window.FLAVOR_TEXT_WELCOME.pick_random())

#Overrided
func interact() -> void:
	_set_shop_window_ref()
	shop_window.equipment_displayer = equipment_displayer
	_generate_new_items()
	
	shop_window.open_shop(self)
	shop_window.visibility_changed.connect(_on_shop_close)
	
	if !ui_handler.inventory.visible:
		ui_handler.toggle_inv()

func _on_shop_close():
	if shop_window.visible: return
	
	interact_complete.emit()
	shop_window.visibility_changed.disconnect(_on_shop_close)

func _set_shop_window_ref() -> void:
	ui_handler = GlobalSignals.ui_handler
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
		
