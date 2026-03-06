extends PanelContainer
class_name ShopItemPanel

@export var inventory_slot: InventorySlot = null
@export var default_button: DefaultButton = null

var item_price:int = 0

func add_item(rarity:Item.ItemRarity, item_lvl:int) -> void:
	#TODO change max tier
	var new_item:Item = ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.RANDOM, item_lvl, 0, rarity)
	
	inventory_slot.remove_item()
	inventory_slot.set_item(new_item)
	
	var price:int = int( new_item.item_value * randf_range(3, 5) )
	item_price = price
	default_button.set_price(price)

func set_item(new_item:Item, price:int) -> void:
	inventory_slot.set_item(new_item)
	item_price = price
	default_button.set_price(price)
