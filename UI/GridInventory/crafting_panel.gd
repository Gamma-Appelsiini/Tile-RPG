extends PanelContainer
class_name CraftingPanel

enum CraftAction {REMOVE_RAND_AFF,REMOVE_SPEF_AFF, ADD_AFF, ADD_ILVL, ADD_MAX_AFF, NOTHING}

@export var inventory_panel:InventoryPanel = null
@export var crafting_equipment_square: EquipmentSquare
@export var affix_container: VBoxContainer
@export var disable_rect: ColorRect
@export var button_name_tool_tip: ButtonNameTooltip
@export var cpu_particles_2d: CPUParticles2D

@export_category("Buttons")
@export var rem_button: ReusableButton
@export var add_a_button: ReusableButton
@export var add_i_button: ReusableButton
@export var add_ma_button: ReusableButton
@export var close_red_button: CloseButton

@export_category("Sounds")
@export var crafting_sound:AudioStream = null
@export var remove_sound:AudioStream = null
@export var error_sound:AudioStream = null


const AFF_PAN_SCENE:PackedScene = preload("res://Tile-RPG/UI/Crafting/affix_panel.tscn")
const AFFIX_PANEL := preload("uid://du6la0lmqbrtj")
const ERROR_COLOR:Color = Color(1.0, 0.01, 0.01, 1.0)
const COST_COLOR:Color = Color(0.0, 0.918, 0.8)

var crafting_equipment:Equipment = null
var equ_tt:ItemTooltip = null
var hovered_ap:AffixPanel = null
var action:CraftAction = CraftAction.NOTHING
var free_affix_panels:Array[AffixPanel] = []
var error:bool = false
var not_enough_ore:bool = false
var anvil:Anvil = null

var setting_on_crafting_square:bool = false
var crafting_costs:Dictionary[CraftAction, int] = {
	CraftAction.ADD_AFF: 1,
	CraftAction.REMOVE_SPEF_AFF: 1,
	CraftAction.ADD_ILVL: 1,
	CraftAction.ADD_MAX_AFF: 1,
}

func _ready() -> void:
	set_process_input(false)
	crafting_equipment_square.inventory_panel = inventory_panel
	crafting_equipment_square.mouse_entered.connect(func(): setting_on_crafting_square = true)
	crafting_equipment_square.mouse_exited.connect(func(): setting_on_crafting_square = false)
	inventory_panel.hidden.connect(hide)
	visibility_changed.connect(_on_vis_changed)
	_connect_buttons()
	GlobalSignals.open_crafting.connect(show)
	
	_add_affix_panels()
	await get_tree().process_frame
	cpu_particles_2d.global_position = crafting_equipment_square.global_position + Vector2(crafting_equipment_square.size.x/2, crafting_equipment_square.size.y/2)
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		_remove_affix()
		set_process_input(false)
	elif event.is_action_pressed("Right Click") or event.is_action_pressed("Esc"):
		set_process_input(false)

func _set_error_message_on_tooltip(message:String) -> void:
	error = true
	button_name_tool_tip.ore_pic_container.hide()
	button_name_tool_tip.cost_label.text = message
	button_name_tool_tip.cost_label.add_theme_color_override("font_color", ERROR_COLOR)

func _set_crafting_costs() -> void:
	not_enough_ore = false
	error = false
	button_name_tool_tip.cost_label.add_theme_color_override("font_color", COST_COLOR)
	button_name_tool_tip.cost_container.show()
	button_name_tool_tip.ore_pic_container.show()
	
	#Add affix
	var affix_amount:int = len(crafting_equipment.suffixes) + len(crafting_equipment.prefixes)
	if affix_amount == 0 or affix_amount == 1: crafting_costs[CraftAction.ADD_AFF] = 1
	else: crafting_costs[CraftAction.ADD_AFF] = affix_amount
	
	if action == CraftAction.ADD_AFF:
		if crafting_costs[CraftAction.ADD_AFF] > 6 or affix_amount >= crafting_equipment.max_affixes * 2: _set_error_message_on_tooltip("Max Affixes")
	
	#Ilvl
	crafting_costs[CraftAction.ADD_ILVL] = crafting_equipment.item_level - crafting_equipment.original_item_level + 1
	if action == CraftAction.ADD_ILVL:
		if crafting_costs[CraftAction.ADD_ILVL] > 3: _set_error_message_on_tooltip("Max Item Lvl")
		
	#Remove affix
	crafting_costs[CraftAction.REMOVE_SPEF_AFF] = 1
	if crafting_equipment.item_rarity == Item.ItemRarity.GOD_ROLL: crafting_costs[CraftAction.REMOVE_SPEF_AFF] = 2
	if action == CraftAction.REMOVE_SPEF_AFF:
		if affix_amount == 0: _set_error_message_on_tooltip("Nothing to Remove")
		
	#Max affix
	crafting_costs[CraftAction.ADD_MAX_AFF] = 3
	if action == CraftAction.ADD_MAX_AFF:
		if crafting_equipment.max_affixes == 3: _set_error_message_on_tooltip("At Max Affix Amount")
	
	if error: return
	
	button_name_tool_tip.cost_label.text = str(crafting_costs[action])
	if inventory_panel.player_crafting_ore < crafting_costs[action]:
		button_name_tool_tip.cost_label.add_theme_color_override("font_color", ERROR_COLOR)
		not_enough_ore = true

func _add_item_level() -> void:
	if error or not_enough_ore:
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	if crafting_equipment == null: return
	var cost:int = crafting_costs[action]

	if !crafting_equipment.increase_item_level():
		print_debug("Could not increase item level")
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
		
	inventory_panel.player_crafting_ore -= cost
	GlobalSignals.play_audio.emit(crafting_sound, AudioManager.AUDIO_TYPE.UI)
	cpu_particles_2d.emitting = true

	_set_crafting_costs()

func _add_max_affix_count() -> void:
	if error or not_enough_ore:
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	if crafting_equipment == null: return
	var cost:int = crafting_costs[action]

	if !crafting_equipment.increase_max_affixes():
		print_debug("Could not increase max affixes")
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	inventory_panel.player_crafting_ore -= cost
	GlobalSignals.play_audio.emit(crafting_sound, AudioManager.AUDIO_TYPE.UI)
	cpu_particles_2d.emitting = true
	_set_crafting_costs()

func _add_affix() -> void:
	if error or not_enough_ore:
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	if crafting_equipment == null: return
	var cost:int = crafting_costs[action]
	
	var new_aff:Affix = crafting_equipment.add_affix()
	if new_aff == null:
		print_debug("Could not add affix")
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
	
	inventory_panel.player_crafting_ore -= cost
	GlobalSignals.play_audio.emit(crafting_sound, AudioManager.AUDIO_TYPE.UI)
	cpu_particles_2d.emitting = true
	crafting_equipment_square._set_gradient_color()
	
	_hide_affix_panels()
	_add_equipment_affixes(crafting_equipment.prefixes)
	_add_equipment_affixes(crafting_equipment.suffixes)
	
	_set_crafting_costs()

func _remove_affix() -> void:
	for ap:AffixPanel in affix_container.get_children():
		ap.glow_effect.self_modulate = Color(1.0, 1.0, 1.0, 0.686)
	
	if crafting_equipment == null: return
	if hovered_ap == null:
		GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
		return
		
	var affix_panel_to_remove:AffixPanel = hovered_ap
	hovered_ap = null
	
	var cost:int = crafting_costs[action]
	GlobalSignals.play_audio.emit(remove_sound, AudioManager.AUDIO_TYPE.UI)
	crafting_equipment.remove_affix(affix_panel_to_remove.affix)
	crafting_equipment_square._set_gradient_color()
	inventory_panel.player_crafting_ore -= cost
	
	_animate_panels_under_removed(affix_panel_to_remove)
	var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(affix_panel_to_remove, "scale:y", 0.01, 0.3)
	await tween.finished
	
	affix_panel_to_remove.hide()
	affix_panel_to_remove.scale.y = 1
	free_affix_panels.push_back(affix_panel_to_remove)
	for ap:AffixPanel in affix_container.get_children(): ap.offset_transform_position.y = 0

func _animate_panels_under_removed(removed_ap:AffixPanel) -> void:
	var animate:bool = false
	for ap:AffixPanel in affix_container.get_children():
		if ap == removed_ap:
			animate = true
		elif animate:
			var tween:Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
			tween.tween_property(ap, "offset_transform_position:y", -ap.size.y + 8, 0.3)

func _connect_buttons() -> void:
	close_red_button.button.pressed.connect(hide)
	
	#Remove affix
	rem_button.texture_button.mouse_entered.connect(func():
		action = CraftAction.REMOVE_SPEF_AFF
		_set_crafting_costs()
		button_name_tool_tip.show_tooltip("Remove Affix", rem_button)
		)
	rem_button.texture_button.mouse_exited.connect(button_name_tool_tip.hide)
	rem_button.texture_button.pressed.connect(func():
		if error or not_enough_ore:
			GlobalSignals.play_audio.emit(error_sound, AudioManager.AUDIO_TYPE.UI)
			return
		for ap:AffixPanel in affix_container.get_children():
			ap.glow_effect.self_modulate = ERROR_COLOR
		set_process_input(true)
		)
	
	#Add affix
	add_a_button.texture_button.mouse_entered.connect(func():
		action = CraftAction.ADD_AFF
		_set_crafting_costs()
		button_name_tool_tip.show_tooltip("Add Affix", add_a_button))
	add_a_button.texture_button.mouse_exited.connect(button_name_tool_tip.hide)
	add_a_button.texture_button.pressed.connect(_add_affix)
	
	#Add item level
	add_i_button.texture_button.mouse_entered.connect(func():
		action = CraftAction.ADD_ILVL
		_set_crafting_costs()
		button_name_tool_tip.show_tooltip("Raise Item Lvl", add_i_button)
		)
	add_i_button.texture_button.mouse_exited.connect(button_name_tool_tip.hide)
	add_i_button.texture_button.pressed.connect(_add_item_level)
	
	#Add max affix
	add_ma_button.texture_button.mouse_entered.connect(func():
		action = CraftAction.ADD_MAX_AFF
		_set_crafting_costs()
		button_name_tool_tip.show_tooltip("Raise Max Affix Count", add_ma_button)
		)
	add_ma_button.texture_button.mouse_exited.connect(button_name_tool_tip.hide)
	add_ma_button.texture_button.pressed.connect(_add_max_affix_count)

func _on_vis_changed() -> void:
	if visible:
		inventory_panel.show()
		return
	
	if anvil:
		anvil.interact_complete.emit()
		anvil = null

	#Add item back to inv on close
	if crafting_equipment_square.inventory_item_in_square:
		if !inventory_panel._place_in_first_free_spot(crafting_equipment_square.inventory_item_in_square):
			inventory_panel._drop_item_on_ground(crafting_equipment_square.inventory_item_in_square)
	
	remove_inv_item_on_crafting_square()

func _hide_affix_panels() -> void:
	for affix_panel:AffixPanel in affix_container.get_children():
		affix_panel.hide()
		free_affix_panels.push_back(affix_panel)

func remove_inv_item_on_crafting_square() -> void:
	crafting_equipment_square.inventory_item_in_square = null
	crafting_equipment = null
	disable_rect.show()
	
	_hide_affix_panels()

func set_inv_item_on_crafting_square(inv_item_to_craft:InventoryItem) -> bool:
	if inv_item_to_craft.item is not Equipment: return false
	
	if inventory_panel.items_in_inventory.has(inv_item_to_craft):
		inventory_panel.items_in_inventory.erase(inv_item_to_craft)
	elif inventory_panel.items_equipped.keys().has(inv_item_to_craft):
		inventory_panel.items_equipped.erase(inv_item_to_craft)

	crafting_equipment_square.inventory_item_in_square = inv_item_to_craft
	inv_item_to_craft.global_position = crafting_equipment_square.global_position
	
	if crafting_equipment_square.size.x > inv_item_to_craft.size.x or crafting_equipment_square.size.y > inv_item_to_craft.size.y:
		inv_item_to_craft.global_position += Vector2((crafting_equipment_square.size.x - inv_item_to_craft.size.x) / 2,
		(crafting_equipment_square.size.y - inv_item_to_craft.size.y) / 2)
		
	inventory_panel.old_equipment_square_before_lifting = crafting_equipment_square
	crafting_equipment = inv_item_to_craft.item as Equipment
	
	if crafting_equipment.item_rarity != Item.ItemRarity.FABLED:
		_add_equipment_affixes(crafting_equipment.prefixes)
		_add_equipment_affixes(crafting_equipment.suffixes)
		disable_rect.hide()
		
	return true

func _add_affix_panels() -> void:
	for number:int in 6:
		var new_affix_panel:AffixPanel = AFFIX_PANEL.instantiate()
		free_affix_panels.push_back(new_affix_panel)
		new_affix_panel.hide()
		affix_container.add_child(new_affix_panel)
		new_affix_panel.mouse_entered.connect(func(): hovered_ap = new_affix_panel)
		new_affix_panel.mouse_exited.connect(func(): hovered_ap = null)

func _add_equipment_affixes(affixes:Array[Affix]) -> void:
	for affix:Affix in affixes:
		var free_aff_panel:AffixPanel = free_affix_panels.pop_back()
		free_aff_panel.set_affix(affix)
		free_aff_panel.show()
