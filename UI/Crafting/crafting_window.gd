extends Control
class_name CraftinWindow

signal window_closed

enum CraftAction {REMOVE_RAND_AFF,REMOVE_SPEF_AFF, ADD_AFF, ADD_ILVL, ADD_MAX_AFF, NOTHING}

@export var aff_container: VBoxContainer = null
@export var rem_aff_button: Button = null
@export var add_aff_button: Button = null
@export var inventory_slot: InventorySlot = null
@export var add_ilvl_button: Button = null
@export var add_max_aff_button: Button = null
@export var cpu_particles_2d: CPUParticles2D = null
@export var button_container: HBoxContainer = null
@export var x_button: XButton = null

const AFF_PAN_SCENE:PackedScene = preload("res://Tile-RPG/UI/Crafting/affix_panel.tscn")
const ITEM_TT_PATH:String = ("res://Tile-RPG/UI/Inventory/item_tooltip.tscn")

var crafting_equipment:Equipment = null
var equ_tt:ItemTooltip = null
var hovered_ap:AffixPanel = null
var action:CraftAction = CraftAction.NOTHING

func _ready() -> void:
	inventory_slot.item_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_slot.array_pos = -2
	_add_tooltip()
	_connect_buttons()
	_disable_buttons()

func _input(event: InputEvent) -> void:
	if !visible: return
	if event.is_action_pressed("Left Click"):
		if action == CraftAction.REMOVE_SPEF_AFF:
			_remove_affix()
		elif action == CraftAction.ADD_AFF:
			_add_affix()

func _disable_buttons() -> void:
	for but:Button in button_container.get_children():
		but.disabled = true

func _enable_buttons() -> void:
	for but:Button in button_container.get_children():
		but.disabled = false

func _close_crafting() -> void:
	window_closed.emit()

func _add_tooltip() -> void:
	equ_tt = load(ITEM_TT_PATH).instantiate()
	equ_tt.visible = false
	add_child(equ_tt)

func _remove_affix() -> void:
	if hovered_ap == null: return
	
	hovered_ap.mouse_exited.disconnect(_ap_exited)
	crafting_equipment.remove_affix(hovered_ap.affix)
	aff_container.remove_child(hovered_ap)
	hovered_ap.queue_free()
	
	equ_tt.generate_tooltip(crafting_equipment)
	cpu_particles_2d.emitting = true
	action = CraftAction.NOTHING

func _add_affix() -> void:
	if crafting_equipment == null: return
	
	var new_aff:Affix = crafting_equipment.add_affix()
	if new_aff == null: return
	
	_add_affix_pan(new_aff)
	equ_tt.generate_tooltip(crafting_equipment)
	cpu_particles_2d.emitting = true
	
	action = CraftAction.NOTHING

func _add_ilvl() -> void:
	var success:bool = crafting_equipment.increase_item_level()
	if !success: return
	
	cpu_particles_2d.emitting = true
	equ_tt.generate_tooltip(crafting_equipment)
	action = CraftAction.NOTHING

func _add_max_aff() -> void:
	var success:bool = crafting_equipment.increase_max_affixes()
	if !success: return
	
	cpu_particles_2d.emitting = true
	action = CraftAction.NOTHING

func _connect_buttons() -> void:
	rem_aff_button.pressed.connect(_set_action.bind(CraftAction.REMOVE_SPEF_AFF))
	add_aff_button.pressed.connect(_set_action.bind(CraftAction.ADD_AFF))
	inventory_slot.mouse_entered.connect(_equ_slot_hovered)
	inventory_slot.mouse_exited.connect(_equ_slot_exited)
	add_ilvl_button.pressed.connect(_set_action.bind(CraftAction.ADD_ILVL))
	add_max_aff_button.pressed.connect(_set_action.bind(CraftAction.ADD_MAX_AFF))
	x_button.x_pressed.connect(_close_crafting)
	
	inventory_slot.item_placed.connect(set_equ)
	inventory_slot.item_removed.connect(clear_equ)

func clear_equ() -> void:
	crafting_equipment = null
	inventory_slot.item_image.texture = null
	inventory_slot.item_in_slot = null

	_clear_affix_panels()
	_disable_buttons()

func set_equ(new_equ:Equipment) -> void:
	crafting_equipment = new_equ
	equ_tt.generate_tooltip(new_equ)
	_add_affix_panels(new_equ.prefixes)
	_add_affix_panels(new_equ.suffixes)
	_enable_buttons()

func _set_action(new_action:CraftAction = CraftAction.NOTHING) -> void:
	action = new_action
	
	if new_action == CraftAction.ADD_AFF:
		_add_affix()
	elif new_action == CraftAction.ADD_MAX_AFF:
		_add_max_aff()
	elif new_action == CraftAction.ADD_ILVL:
		_add_ilvl()

func _clear_affix_panels() -> void:
	for child:Control in aff_container.get_children():
		if child is not Label:
			aff_container.remove_child(child)
			child.queue_free()

func _add_affix_panels(aff_array:Array[Affix]) -> void:
	for aff:Affix in aff_array:
		_add_affix_pan(aff)

func _add_affix_pan(aff:Affix) -> void:
	var new_aff_panel:AffixPanel = AFF_PAN_SCENE.instantiate()
	aff_container.add_child(new_aff_panel)
	new_aff_panel.set_affix(aff)
	
	new_aff_panel.mouse_entered.connect(_ap_hovered.bind(new_aff_panel))
	new_aff_panel.mouse_exited.connect(_ap_exited.bind(new_aff_panel))

func _ap_hovered(ap:AffixPanel) -> void:
	hovered_ap = ap
	var to_delete:bool = false
	if action == CraftAction.REMOVE_SPEF_AFF: to_delete = true
	hovered_ap.show_glow(to_delete)
	
func _ap_exited(ap:AffixPanel) -> void:
	if hovered_ap == ap: hovered_ap = null
	ap.hide_glow()

func _equ_slot_hovered() -> void:
	_show_tt()
	
func _equ_slot_exited() -> void:
	equ_tt.visible = false

func _show_tt() -> void:
	if crafting_equipment == null: return

	equ_tt.visible = true
	var offset_x:float = inventory_slot.size.x + 25
	var offset_y:float = (inventory_slot.size.y) / 4
	equ_tt.global_position = inventory_slot.global_position + Vector2(offset_x,-offset_y)
