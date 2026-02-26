extends PanelContainer
class_name ShopWindow

const SHOP_ITEM_PANEL := preload("uid://dq3yj14tiaaho")

@onready var shop_items_container: GridContainer = $ShopItemsContainer

func _ready() -> void:
	pass

func _fill_items() -> void:
	pass
