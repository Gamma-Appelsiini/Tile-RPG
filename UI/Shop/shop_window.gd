extends PanelContainer
class_name ShopWindow

const SHOP_ITEM_PANEL := preload("uid://dq3yj14tiaaho")
const SHOP_ITEM_AMOUNT:int = 8
const SELL_TEXT:String = "Drop to Sell"
const RARITIES:Array[Item.ItemRarity] = [Item.ItemRarity.POOR,Item.ItemRarity.POOR,
	Item.ItemRarity.COMMON,Item.ItemRarity.COMMON, Item.ItemRarity.RARE, Item.ItemRarity.RARE, Item.ItemRarity.EPIC, Item.ItemRarity.LEGENDARY]
	
const FLAVOR_TEXT_BUY:Array[String] = ["Sold. For a good price.", "Good choice.", "I would have bought the same one myself."]
const FLAVOR_TEXT_SELL:Array[String] = ["I'll take it off you.", "Where did you find this one?", "A common item."]
const FLAVOR_TEXT_GOODBYE:Array[String] = ["Come back again.", "You're my best customer.", "Great deals here again tomorrow."]

@export var shop_items_container: GridContainer = null
@export var purchase_sound:AudioStream = null
@export var sell_sound:AudioStream = null
@export var player_inventory:Inventory = null
@export var sell_label: Label = null
@export var viewport_rect: TextureRect = null
@export var sell_container: PanelContainer = null
@export var flavor_text_panel: DialoguePanel = null
@export var shopkeeper_portrait: DialoguePortrait = null

var item_panels:Array[ShopItemPanel] = []
var viewport_texture:ViewportTexture = null
var equipment_displayer:EquipmentDisplayer = null
var opened_shop:Shop = null

func _animate_flavor_text(new_text:String) -> void:
	flavor_text_panel.set_text(new_text)
	await flavor_text_panel.text_ready

func _show_goodbye_text() -> void:
	if visible: return
	opened_shop.show_shopkeeper_talking(FLAVOR_TEXT_GOODBYE.pick_random())

func _on_inv_visibility_changed() -> void:
	if !player_inventory.visible: self.visible = false

func _ready() -> void:
	_add_slots()
	sell_container.mouse_entered.connect(_on_mouse_enter_sell_area)
	sell_container.mouse_exited.connect(_on_mouse_leave_sell_area)
	player_inventory.sell_item.connect(sell_item)
	player_inventory.visibility_changed.connect(_on_inv_visibility_changed)
	viewport_texture = ViewportTexture.new()
	
	flavor_text_panel.show_continue_rect = false
	self.visibility_changed.connect(_show_goodbye_text)

func reset_shop() -> void:
	for item_panel:ShopItemPanel in item_panels:
		item_panel.inventory_slot.remove_item()
		item_panel.default_button.reset_button()

func open_shop(new_shop:Shop) -> void:
	opened_shop = new_shop
	
	_set_viewport()
	shopkeeper_portrait.set_shopkeeper(new_shop)
	
	show()

func _set_viewport() -> void:
	if viewport_rect.texture is ViewportTexture:
		viewport_texture = viewport_rect.texture
		viewport_texture.viewport_path = equipment_displayer.sub_viewport.get_path()
		
func _add_slots() -> void:
	#Lootwindow has 10 slots
	var pos:int = player_inventory.INV_SIZE + 10
	for i:int in SHOP_ITEM_AMOUNT:
		var new_item_panel:ShopItemPanel = SHOP_ITEM_PANEL.instantiate()
		item_panels.push_back(new_item_panel)
		shop_items_container.add_child(new_item_panel)
		new_item_panel.default_button.purchased.connect(_buy_item.bind(new_item_panel))
		
		var new_slot:InventorySlot = new_item_panel.inventory_slot
		new_slot.dragging_disabled = true
		new_slot.array_pos = pos + i
		player_inventory.connect_slot(new_slot)
		
		new_slot.mouse_entered.connect(_show_item_model.bind(new_slot))
		new_slot.mouse_exited.connect(_hide_item_model)
		
func _show_item_model(item_slot:InventorySlot) -> void:
	var new_item:Item = item_slot.item_in_slot
	if new_item == null or equipment_displayer == null: return
	
	equipment_displayer.set_item_to_display(new_item)
	
func _hide_item_model() -> void:
	if equipment_displayer == null: return
	equipment_displayer.remove_model()

func _on_mouse_enter_sell_area() -> void:
	player_inventory.sell_item_on_release = true
	if !player_inventory.selected_slot: return
	
	var item_to_sell:Item = player_inventory.selected_slot.item_in_slot
	sell_label.text = "Sell for " + str(item_to_sell.item_value) + " bux"
	sell_label.add_theme_color_override("font_color", Color(0.8, 0.056, 0.316, 1.0))
	
func _on_mouse_leave_sell_area() -> void:
	player_inventory.sell_item_on_release = false
	sell_label.text = SELL_TEXT
	sell_label.remove_theme_color_override("font_color")

func fill_items() -> void:
	for item_panel:ShopItemPanel in item_panels:
		item_panel.default_button.reset_button()
		var max_item_level:int = GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
		item_panel.add_item(RARITIES.pick_random(), max_item_level)
		player_inventory._create_item_tt(item_panel.inventory_slot.item_in_slot)
		

func _buy_item(item_panel:ShopItemPanel) -> void:
	var player_cash:int = player_inventory.player_currency
	
	if item_panel.item_price > player_cash: return
	if player_inventory.get_empty_item_space() < 1: return
	
	GlobalSignals.play_audio.emit(purchase_sound, AudioManager.AUDIO_TYPE.UI)
	item_panel.default_button.set_as_sold()
	player_inventory.player_currency = player_cash - item_panel.item_price
	
	player_inventory.add_item_to_inv(item_panel.inventory_slot.item_in_slot)
	item_panel.inventory_slot.remove_item()
	
	_animate_flavor_text(FLAVOR_TEXT_BUY.pick_random())

func sell_item(item:Item) -> void:
	if item.unsellable: return

	GlobalSignals.play_audio.emit(sell_sound, AudioManager.AUDIO_TYPE.UI)
	player_inventory.remove_item_from_inv(item)
	player_inventory.player_currency += item.item_value
	
	_animate_flavor_text(FLAVOR_TEXT_SELL.pick_random())
	
