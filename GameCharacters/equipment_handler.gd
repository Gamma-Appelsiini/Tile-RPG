extends Node
class_name EquipmentHandler

var equipment_owner:GameCharacter = null
var equipped_items:Dictionary[Equipment.EquipmentSlot, Equipment] = {
	Equipment.EquipmentSlot.MAIN_HAND: null,
	Equipment.EquipmentSlot.OFF_HAND: null,
	Equipment.EquipmentSlot.FEET: null,
	Equipment.EquipmentSlot.HEAD: null,
	Equipment.EquipmentSlot.NECK: null,
	Equipment.EquipmentSlot.FINGER: null,
	Equipment.EquipmentSlot.CHEST: null,
	Equipment.EquipmentSlot.HANDS: null,
	Equipment.EquipmentSlot.WAIST: null
}

var in_combat:bool = false
var owner_turn:bool = false
var main_hand_model:ItemModel = null
var off_hand_model:ItemModel = null

func _ready() -> void:
	set_handler_owner()

func set_handler_owner() -> void:
	if get_parent() is GameCharacter:
		var new_owner:GameCharacter = get_parent() as GameCharacter
		if equipment_owner == new_owner: return
		
		equipment_owner = new_owner
		_connect_signals()
	
func set_item_models_on_load() -> void:
	_set_item_model(equipped_items[Equipment.EquipmentSlot.MAIN_HAND])
	_set_item_model(equipped_items[Equipment.EquipmentSlot.OFF_HAND])

func _connect_signals() -> void:
	GlobalSignals.combat_start.connect(func(): in_combat = true)
	GlobalSignals.combat_end.connect(func(): in_combat = false)
	
	if equipment_owner:
		equipment_owner.start_turn.connect(func(): owner_turn = true)
		equipment_owner.end_turn.connect(func(): owner_turn = false)
		equipment_owner.draw_weapon.connect(_show_equipped_weapon)
		equipment_owner.hide_weapon.connect(_hide_equipped_weapon)

func _show_equipped_weapon() -> void:
	if main_hand_model:
		main_hand_model.show()
	if off_hand_model: off_hand_model.show()
	
func _hide_equipped_weapon() -> void:
	if main_hand_model: main_hand_model.hide()
	if off_hand_model: off_hand_model.hide()

func can_equip() -> bool:
	if !in_combat: return true
	if !owner_turn: return false
	
	var current_ap:int = equipment_owner.stat_handler.resources[Stats.ResourceStat.CURRENT_AP]
	if current_ap <= 0: return false
	
	equipment_owner.stat_handler.update_stat(Stats.ResourceStat.CURRENT_AP, -1)
	return true

func equip_item(new_item:Equipment, skip_stats:bool = false) -> void:
	unequip_item(new_item.equipment_slot)
	_set_item_model(new_item)
	
	if skip_stats:
		equipped_items[new_item.equipment_slot] = new_item
		return
	
	if new_item is Armor:_equip_armor_def(new_item)
	elif new_item is Weapon: _equip_weapon(new_item)
	elif new_item is Jewellery: _equip_jewellery(new_item)
	
	for pref:Affix in new_item.prefixes:
		pref.apply_to_character(equipment_owner)
	for suf in new_item.suffixes:
		suf.apply_to_character(equipment_owner)
		
	equipped_items[new_item.equipment_slot] = new_item

func _clear_item_model(equipment_slot:Equipment.EquipmentSlot) -> void:
	if equipment_slot == Equipment.EquipmentSlot.OFF_HAND and off_hand_model:
		off_hand_model.queue_free()
		off_hand_model = null
		
	elif equipment_slot == Equipment.EquipmentSlot.MAIN_HAND and main_hand_model:
		main_hand_model.queue_free()
		main_hand_model = null

func _set_item_model(new_item:Equipment) -> void:
	if new_item == null: return
	if new_item.item_model_path == "":
		print_debug("null item model path")
		return
	var item_model:ItemModel = load(new_item.item_model_path).instantiate()
	
	if new_item.equipment_slot == Equipment.EquipmentSlot.OFF_HAND:
		off_hand_model = item_model
		if new_item is Shield: equipment_owner.char_model_handler.shield_node.add_child(item_model)
		else: equipment_owner.char_model_handler.off_hand_node.add_child(item_model)
		
		if !in_combat: off_hand_model.hide()
		else: off_hand_model.show()

	elif new_item.equipment_slot == Equipment.EquipmentSlot.MAIN_HAND:
		main_hand_model = item_model
		equipment_owner.char_model_handler.main_hand_node.add_child(main_hand_model)
	
		if !in_combat: main_hand_model.hide()
		else: main_hand_model.show()

func unequip_item(equipment_slot:Equipment.EquipmentSlot) -> void:
	var item_to_unequip:Equipment = equipped_items[equipment_slot]
	if item_to_unequip == null: return
	_clear_item_model(equipment_slot)
	
	if item_to_unequip is Armor: _remove_armor_def(item_to_unequip)
	elif item_to_unequip is Jewellery: _unequip_jewellery(item_to_unequip)
	
	for pref in item_to_unequip.prefixes:
		pref.remove_from_character(equipment_owner)
	for suf in item_to_unequip.suffixes:
		suf.remove_from_character(equipment_owner)
		
	equipped_items[equipment_slot] = null
	
func _equip_weapon(weapon_to_equip:Weapon) -> void:
	if weapon_to_equip.hand_type == Weapon.HandType.TWO_HANDED:
		unequip_item(Equipment.EquipmentSlot.OFF_HAND)

func _equip_jewellery(jewel:Jewellery) -> void:
	equipment_owner.stat_handler.update_stat(jewel.base_skill, jewel.skill_amount)
	
func _unequip_jewellery(jewel:Jewellery) -> void:
	equipment_owner.stat_handler.update_stat(jewel.base_skill, jewel.skill_amount * -1)

func _remove_armor_def(armor_to_remove:Armor) -> void:
	equipment_owner.stat_handler.update_stat(armor_to_remove.defence_type, armor_to_remove.total_defence * -1)

func _equip_armor_def(armor_to_equip:Armor) -> void:
	equipment_owner.stat_handler.update_stat(armor_to_equip.defence_type, armor_to_equip.total_defence)
