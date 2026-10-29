extends Interactable
class_name Shop

const DIALOGUE_BUBBLE := preload("uid://b7q77u7wvwvi3")

@export var shop_resource:ShopResource = null
@export var equipment_displayer:EquipmentDisplayer = null
@export var dialogue_place:Node3D = null
@export var enter_area:Area3D = null

var shop_save_data:Dictionary = {
	"currency_amount": 0,
	"last_open_lvl": -1,
	"items": [],
	"prices": [],
}

var shop_panel:ShopPanel = null
var last_open_lvl:int = -1
var inventory_panel:InventoryPanel = null
var ui_handler:UIHandler = null
var dialogue_on_cd:bool = false

#Overrided
func _ready() -> void:
	_on_creation()
	if enter_area:
		enter_area.connect("body_entered", Callable(self, "_on_enter_area_entered"))

func _on_enter_area_entered(body:Node) -> void:
	if body is not Player: return
	
	show_shopkeeper_talking(shop_resource.FLAVOR_TEXT_WELCOME.pick_random())
	enter_area.set_deferred("monitoring", false)

func show_shopkeeper_talking(new_text:String) -> void:
	if dialogue_on_cd: return
	dialogue_on_cd = true
	
	var new_dialogue_bubble:DialogueBubble = DIALOGUE_BUBBLE.instantiate()
	add_child(new_dialogue_bubble)
	new_dialogue_bubble.set_params(shop_resource.shop_name,shop_resource.shop_portrait, dialogue_place, get_viewport().get_camera_3d())
	new_dialogue_bubble.set_simple_dialogue(new_text)

	await new_dialogue_bubble.dialogue_finished
	dialogue_on_cd = false

#Overrided
func interact() -> void:
	_set_shop_window_ref()
	shop_panel.equipment_displayer = equipment_displayer
	
	shop_panel.open_shop(shop_resource)
	shop_panel.show()
	shop_panel.hidden.connect(_on_shop_close)

func _on_shop_close():
	interact_complete.emit()
	shop_panel.hidden.disconnect(_on_shop_close)

func _set_shop_window_ref() -> void:
	ui_handler = GlobalSignals.ui_handler
	shop_panel = ui_handler.shop_panel
	inventory_panel = ui_handler.inventory_panel

#Overrided
func save_to_data(save_data:Dictionary) -> void:
	#TODO
	return
	
	if unique_id == "":
		print_debug("ERROR NO UNIQUE ID FOR SHOP")
		return
	
	_set_shop_window_ref()
	var item_array:Array[Dictionary] = []
	var price_array:Array[int] = []
	
	shop_save_data = {
		"currency_amount": inventory_panel.player_currency,
		"items": item_array,
		"prices": price_array,
	}
	#for item_panel:ShopItemPanel in shop_window.item_panels:
		#if item_panel.inventory_slot.item_in_slot == null: continue
		#item_array.push_back(item_panel.inventory_slot.item_in_slot.save_to_data())
		#price_array.push_back(item_panel.item_price)
		
	shop_save_data["last_open_lvl"] = last_open_lvl
	save_data["shops"][unique_id] = shop_save_data

#Overrided
func load_from_data(save_data:Dictionary) -> void:
	#TODO
	return
	
	if unique_id == "":
		print_debug("ERROR NO UNIQUE ID FOR SHOP")
		return
	if !save_data["shops"].has(unique_id): return
	
	_set_shop_window_ref()
	#shop_window.reset_shop()
	
	var shop_data:Dictionary = save_data["shops"][unique_id]
	
	last_open_lvl = shop_data["last_open_lvl"]
	inventory_panel.player_currency = shop_data["currency_amount"]
	var item_array:Array[Dictionary] = shop_data["items"]
	var price_array:Array[int] = shop_data["prices"]
	
	for i:int in len(item_array):
		var script: Script = load(item_array[i]["item_type"])
		var loaded_item:Item = script.new()

		loaded_item.load_from_data(item_array[i])
		#shop_window.item_panels[i].set_item(loaded_item, price_array[i])
		
