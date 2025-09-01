extends Control
class_name CraftinWindow

enum CraftAction {REMOVE_RAND_AFF,REMOVE_SPEF_AFF, ADD_AFF, ADD_ILVL, ADD_MAX_AFF, NOTHING}

@onready var aff_container: VBoxContainer = %AffContainer
@onready var rem_aff_button: Button = %RemAffButton
@onready var add_aff_button: Button = %AddAffButton
@onready var inventory_slot: InventorySlot = %InventorySlot
@onready var add_ilvl_button: Button = %AddIlvlButton
@onready var add_max_aff_button: Button = %AddMaxAffButton
@onready var cpu_particles_2d: CPUParticles2D = $PanelContainer/VBoxContainer/CPUParticles2D

const AFF_PAN_SCENE:PackedScene = preload("res://Tile-RPG/UI/Crafting/affix_panel.tscn")
const ITEM_TT_PATH:String = ("res://Tile-RPG/UI/Inventory/item_tooltip.tscn")

var crafting_equipment:Equipment = null
var equ_tt:ItemTooltip = null
var hovered_ap:AffixPanel = null
var action:CraftAction = CraftAction.NOTHING

func _ready() -> void:
	inventory_slot.item_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_tooltip()
	_connect_buttons()
	
	set_equ(ItemGenerator.get_random_equipment(1,0,Item.ItemRarity.RARE))

func _input(event: InputEvent) -> void:
	if !visible: return
	if event.is_action_pressed("Left Click"):
		if action == CraftAction.REMOVE_SPEF_AFF:
			_remove_affix()
		elif action == CraftAction.ADD_AFF:
			_add_affix()

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

func set_equ(new_equ:Equipment) -> void:
	crafting_equipment = new_equ
	inventory_slot.set_item(new_equ)
	equ_tt.generate_tooltip(new_equ)
	_add_affix_panels(new_equ.prefixes)
	_add_affix_panels(new_equ.suffixes)
		
func _set_action(new_action:CraftAction = CraftAction.NOTHING) -> void:
	action = new_action
	
	if new_action == CraftAction.ADD_AFF:
		_add_affix()
	elif new_action == CraftAction.ADD_MAX_AFF:
		_add_max_aff()
	elif new_action == CraftAction.ADD_ILVL:
		_add_ilvl()

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
