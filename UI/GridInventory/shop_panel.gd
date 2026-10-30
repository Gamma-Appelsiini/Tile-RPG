extends MarginContainer
class_name ShopPanel

@export_category("Sounds")
@export var gold_sound:AudioStream = null

@export_category("Elements")
@export var inventory_panel:InventoryPanel = null
@export var inv_square_container: GridContainer
@export var dialogue_portrait: DialoguePortrait
@export var dialogue_panel: DialoguePanel
@export var viewport_rect: TextureRect
@export var close_red_button: CloseButton
@export var prompt_panel: PromptContainer
@export var squares_container: PanelContainer
@export var cpu_particles_2d: CPUParticles2D

const INVENTORY_ITEM := preload("uid://cvit4tuvaxa2t")
const INVENTORY_SQUARE := preload("uid://6sfv2oiat16b")
const SQUARE_AMOUNT:int = 120
const TEST_SHOP_RESOURCE := preload("uid://cyp0vy4ph7gsq")

var inv_item_to_purchase:InventoryItem = null
var shop_resource:ShopResource = null
var selling_item:bool = false
var equipment_displayer:EquipmentDisplayer = null

func _ready() -> void:
	dialogue_panel.set_text("")
	set_process(false)
	visibility_changed.connect(_on_vis_changed)
	close_red_button.button.pressed.connect(hide)
	inventory_panel.shop_panel = self
	_add_squares()
	await get_tree().process_frame
	hide()

func _process(_delta: float) -> void:
	if _is_mouse_outside_of_sell_area():
		selling_item = false
		prompt_panel.cancel_prompt()
		set_process(false)

func _set_viewport() -> void:
	viewport_rect.texture = equipment_displayer.sub_viewport.get_texture()

func _is_mouse_outside_of_sell_area() -> bool:
	const BUFFER: int = 5
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var container_pos: Vector2 = inv_square_container.global_position
	var container_size: Vector2 = inv_square_container.size

	if mouse_pos.x - BUFFER > container_pos.x + container_size.x: return true
	if mouse_pos.x + BUFFER < container_pos.x: return true
	if mouse_pos.y - BUFFER > container_pos.y + container_size.y: return true
	if mouse_pos.y + BUFFER < container_pos.y: return true

	return false

func _on_vis_changed() -> void:
	if visible:
		inventory_panel.show()
		return
	
	if shop_resource: shop_resource.save_to_data(inventory_panel.items_in_shop)
	await get_tree().process_frame
	prompt_panel.cancel_prompt()
	set_process(false)
	inventory_panel.hide()
	_reset_shop_panel()

func _reset_shop_panel() -> void:
	for inv_item:InventoryItem in inventory_panel.shop_inventory_items:
		inv_item.mouse_entered.disconnect(equipment_displayer.set_item_to_display.bind(inv_item.item))
		inv_item.mouse_exited.disconnect(equipment_displayer.remove_model)
		inv_item.remove_item()
		
	inventory_panel.shop_inventory_items = []
	inventory_panel.items_in_shop = {}
	dialogue_panel.set_text("")
	
	for square:InventorySquare in inventory_panel.shop_squares_dict.values():
		square.inv_item_in_square = null
		square.occupied = false

func _add_squares() -> void:
	for number:int in SQUARE_AMOUNT:
		var new_inv_square:InventorySquare = INVENTORY_SQUARE.instantiate()
		inv_square_container.add_child(new_inv_square)
		
		new_inv_square.pos_x = number % inv_square_container.columns
		new_inv_square.pos_y = int(number / inv_square_container.columns)
		inventory_panel.shop_squares_dict[Vector2i(new_inv_square.pos_x, new_inv_square.pos_y)] = new_inv_square
		
		new_inv_square.mouse_entered.connect(func(): inventory_panel.hovered_square = new_inv_square)
		new_inv_square.mouse_exited.connect(func(): if inventory_panel.hovered_square == new_inv_square: inventory_panel.hovered_square = null)
		new_inv_square.mouse_entered.connect(set_for_sale)

func set_for_sale() -> void:
	if !inventory_panel.lifted_inv_item: return
	if selling_item: return
	
	selling_item = true
	prompt_panel.set_item_for_sale(inventory_panel.lifted_inv_item.item)
	set_process(true)

func sell_item(item_to_sell:Item) -> void:
	GlobalSignals.play_audio.emit(gold_sound, AudioManager.AUDIO_TYPE.UI)
	inventory_panel.player_currency += item_to_sell.item_value
	prompt_panel.cancel_prompt()
	
	cpu_particles_2d.restart()
	cpu_particles_2d.global_position = get_viewport().get_mouse_position() + Vector2(-cpu_particles_2d.emission_sphere_radius/2, -cpu_particles_2d.emission_sphere_radius/2)
	cpu_particles_2d.emitting = true
	dialogue_panel.set_text(shop_resource.FLAVOR_TEXT_SELL.pick_random())

func set_for_purhcase(shop_inv_item:InventoryItem) -> void:
	inv_item_to_purchase = shop_inv_item
	if !prompt_panel.pressed_label.is_connected(_prompt_pressed):
		prompt_panel.pressed_label.connect(_prompt_pressed)
	prompt_panel.set_item_for_purchase(shop_inv_item.item)
	prompt_panel.global_position = shop_inv_item.global_position + Vector2(-prompt_panel.size.x / 2 + shop_inv_item.size.x / 2, shop_inv_item.size.y / 2 - prompt_panel.size.y / 2)
	prompt_panel.show()
	
func _prompt_pressed(purchased:bool) -> void:
	await get_tree().process_frame
	prompt_panel.pressed_label.disconnect(_prompt_pressed)
	if !inv_item_to_purchase or !purchased: return
	
	if inv_item_to_purchase.item.item_value > inventory_panel.player_currency:
		prompt_panel.set_error_message("Not enough Bux")
		dialogue_panel.set_text(shop_resource.FLAVOR_TEXT_NOT_ENOUGH_BUX.pick_random())
		prompt_panel.show()
		return
	elif !inventory_panel.add_item_to_inv(inv_item_to_purchase.item):
		prompt_panel.set_error_message("Not enough inventory space")
		prompt_panel.show()
		return
	
	dialogue_panel.set_text(shop_resource.FLAVOR_TEXT_BUY.pick_random())
	GlobalSignals.play_audio.emit(gold_sound, AudioManager.AUDIO_TYPE.UI)
	inventory_panel.player_currency -= inv_item_to_purchase.item.item_value
	_remove_inv_item_from_shop(inv_item_to_purchase)
	inv_item_to_purchase = null

func _remove_inv_item_from_shop(to_remove:InventoryItem) -> void:
	inventory_panel.remove_item_from_shop(to_remove.item)

func open_shop(new_shop_resource:ShopResource) -> void:
	_set_viewport()
	self.shop_resource = new_shop_resource
	
	if !shop_resource.load_from_data():
		while _add_item_to_shop(shop_resource.shop_level): pass
	elif GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL) > shop_resource.last_open_lvl:
		while _add_item_to_shop(shop_resource.shop_level): pass
	else:
		for inv_item:InventoryItem in inventory_panel.shop_inventory_items:
			inv_item.mouse_entered.connect(equipment_displayer.set_item_to_display.bind(inv_item.item))
			inv_item.mouse_exited.connect(equipment_displayer.remove_model)

func _add_item_to_shop(max_tier:int) -> bool:
	#GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL)
	var max_item_level:int = 1
	var new_equipment:Equipment = ItemGenerator.get_equipment(ItemGenerator.LOOT_TYPE.RANDOM, max_item_level,max_tier, Item.ItemRarity.RANDOM)
	var added:bool = inventory_panel.add_item_to_shop(new_equipment)
	
	if added:
		var added_inventory_item:InventoryItem = inventory_panel.shop_inventory_items.back()
		added_inventory_item.mouse_entered.connect(equipment_displayer.set_item_to_display.bind(added_inventory_item.item))
		added_inventory_item.mouse_exited.connect(equipment_displayer.remove_model)

	return added
