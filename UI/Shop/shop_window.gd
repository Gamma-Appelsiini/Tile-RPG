extends PanelContainer
class_name ShopWindow

const SHOP_ITEM_PANEL := preload("uid://dq3yj14tiaaho")
const SHOP_ITEM_AMOUNT:int = 8
const SELL_TEXT:String = "Drop to Sell"
const RARITIES:Array[Item.ItemRarity] = [Item.ItemRarity.POOR,Item.ItemRarity.POOR,
	Item.ItemRarity.COMMON,Item.ItemRarity.COMMON, Item.ItemRarity.RARE, Item.ItemRarity.RARE, Item.ItemRarity.EPIC, Item.ItemRarity.LEGENDARY]

@export var shop_items_container: GridContainer = null
@export var purchase_sound:AudioStream = null
@export var player_inventory:Inventory = null
@export var sell_label: Label = null
@export var viewport_rect: TextureRect = null

var item_panels:Array[ShopItemPanel] = []

func _ready() -> void:
	_fill_items()

func _add_slots() -> void:
	#Lootwindow has 10 slots
	var pos:int = player_inventory.INV_SIZE + 10
	for i:int in SHOP_ITEM_AMOUNT:
		var new_item_panel:ShopItemPanel = SHOP_ITEM_PANEL.instantiate()
		item_panels.push_back(new_item_panel)
		shop_items_container.add_child(new_item_panel)
		
		var new_slot:InventorySlot = new_item_panel.inventory_slot
		new_slot.array_pos = pos + i
		player_inventory.connect_slot(new_slot)

func _on_mouse_enter_sell_area() -> void:
	if !player_inventory.selected_slot: return
	
	var item_to_sell:Item = player_inventory.selected_slot.item_in_slot
	sell_label.text = "Sell for " + str(item_to_sell.item_value)
	sell_label.add_theme_color_override("font_color", Color(0.8, 0.056, 0.316, 1.0))
	
func _on_mouse_leave_sell_area() -> void:
	sell_label.text = SELL_TEXT
	sell_label.remove_theme_color_override("font_color")

func _fill_items() -> void:
	for item_panel:ShopItemPanel in item_panels:
		var max_item_level:int = GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
		item_panel.add_item(RARITIES.pick_random(), max_item_level)
		item_panel.default_button.purchased.connect(_buy_item.bind(item_panel))

func _buy_item(item_panel:ShopItemPanel) -> void:
	var player_cash:int = GlobalSignals.ui_handler.player_inventory.player_currency
	
	if item_panel.default_button.item_price > player_cash: return
	if GlobalSignals.ui_handler.player_inventory.get_empty_item_space() < 1: return
	
	GlobalSignals.play_audio.emit(purchase_sound, AudioManager.AUDIO_TYPE.UI)
	item_panel.default_button.set_as_sold()
	GlobalSignals.ui_handler.player_inventory.player_currency = player_cash - item_panel.default_button.item_price
	
	GlobalSignals.ui_handler.player_inventory.add_item_to_inv(item_panel.inventory_slot.item_in_slot)
	item_panel.inventory_slot.remove_item()

func sell_item(item_to_sell:Item) -> void:
	if item_to_sell.unsellable: return
	
	GlobalSignals.ui_handler.player_inventory.remove_item_from_inv(item_to_sell, true)
	GlobalSignals.ui_handler.player_inventory.player_currency += item_to_sell.item_value
	
