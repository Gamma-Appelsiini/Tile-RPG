extends PanelContainer
class_name ShopWindow

const SHOP_ITEM_PANEL := preload("uid://dq3yj14tiaaho")
const ITEM_AMOUNT:int = 8
const RARITIES:Array[Item.ItemRarity] = [Item.ItemRarity.POOR,Item.ItemRarity.POOR,
	Item.ItemRarity.COMMON,Item.ItemRarity.COMMON, Item.ItemRarity.RARE, Item.ItemRarity.RARE, Item.ItemRarity.EPIC, Item.ItemRarity.LEGENDARY]

@export var shop_items_container: GridContainer = null
@export var purchase_sound:AudioStream = null

func _ready() -> void:
	_fill_items()

func _fill_items() -> void:
	for i:int in ITEM_AMOUNT:
		var new_item_panel:ShopItemPanel = SHOP_ITEM_PANEL.instantiate()
		shop_items_container.add_child(new_item_panel)
		var max_item_level:int = GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
		new_item_panel.add_item(RARITIES[i], max_item_level)
		new_item_panel.default_button.purchased.connect(_buy_item.bind(new_item_panel))

func _buy_item(item_panel:ShopItemPanel) -> void:
	var player_cash:int = 0
	if item_panel.default_button.item_price > player_cash: return
	
	GlobalSignals.play_audio.emit(purchase_sound, AudioManager.AUDIO_TYPE.UI)
	item_panel.default_button.set_as_sold()
