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

func equip_item(new_item:Equipment) -> void:
	unequip_item(new_item.equipment_slot)
	
	if new_item is Armor:_equip_armor_def(new_item)
	elif new_item is Weapon: _equip_weapon(new_item)
	elif new_item is Jewellery: _equip_jewellery(new_item)
	
	for pref:Affix in new_item.prefixes:
		pref.apply_to_character(equipment_owner)
	for suf in new_item.suffixes:
		suf.apply_to_character(equipment_owner)
		
	equipped_items[new_item.equipment_slot] = new_item
	
func unequip_item(equipment_slot:Equipment.EquipmentSlot) -> void:
	var item_to_unequip:Equipment = equipped_items[equipment_slot]
	if item_to_unequip == null: return
	
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
