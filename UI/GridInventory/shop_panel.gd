extends MarginContainer
class_name ShopPanel

@export var inventory_panel:InventoryPanel = null
@export var inv_square_container: GridContainer
@export var dialogue_portrait: DialoguePortrait
@export var dialogue_panel: DialoguePanel
@export var viewport_rect: TextureRect
@export var close_red_button: CloseButton

const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const SQUARE_AMOUNT:int = 120
const TEST_SHOP_RESOURCE := preload("uid://cyp0vy4ph7gsq")

var shop_items:Array[InventoryItem] = []

func _ready() -> void:
	visibility_changed.connect(_on_vis_changed)
	close_red_button.button.pressed.connect(hide)
	inventory_panel.shop_panel = self
	_add_squares()
	await get_tree().process_frame
	await get_tree().create_timer(.2).timeout
	
	open_shop(TEST_SHOP_RESOURCE)

func _on_vis_changed() -> void:
	if visible:
		inventory_panel.show()
		return
		
	inventory_panel.hide()

func _add_squares() -> void:
	for number:int in SQUARE_AMOUNT:
		var new_inv_square:InventorySquare = INVENTORY_SQUARE.instantiate()
		inv_square_container.add_child(new_inv_square)
		
		new_inv_square.pos_x = number % inv_square_container.columns
		new_inv_square.pos_y = int(number / inv_square_container.columns)
		inventory_panel.shop_squares_dict[Vector2i(new_inv_square.pos_x, new_inv_square.pos_y)] = new_inv_square
		
		new_inv_square.mouse_entered.connect(func(): inventory_panel.hovered_square = new_inv_square)
		new_inv_square.mouse_exited.connect(func(): if inventory_panel.hovered_square == new_inv_square: inventory_panel.hovered_square = null)

func open_shop(shop_resource:ShopResource) -> void:
	while _add_item_to_shop(shop_resource.shop_level): pass

func _add_item_to_shop(max_tier:int) -> bool:
	#GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
	var max_item_level:int = 1
	var new_equipment:Equipment = ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.RANDOM, max_item_level,max_tier, Item.ItemRarity.RANDOM)
	return inventory_panel.add_item_to_shop(new_equipment)
