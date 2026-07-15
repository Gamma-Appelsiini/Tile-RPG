extends Node
class_name StatusHandler

signal status_added(status:Status)
signal status_removed(status:Status)

const GENERIC_BUFF_EFFECT := preload("uid://b8xk37t3i1ps4")
const GENERIC_DEBUFF_EFFECT := preload("uid://duwkcoksgw1mw")
const STUN_RESISTANCE_PER_STUN:int = 35

var buffs:Array[Status] = []
var debuffs:Array[Status] = []
var gchar:GameCharacter = null
var stun_resistance:int = 0

func _ready() -> void:
	if get_parent() is GameCharacter: gchar = get_parent()
	gchar.start_turn.connect(_reduce_stun_resistance)

func _reduce_stun_resistance() -> void:
	stun_resistance = clamp(stun_resistance - 25, 0, 100)

func has_status(name_to_check:String) -> bool:
	var all_statuses:Array[Status] = buffs.duplicate() + debuffs.duplicate()
	for status:Status in all_statuses:
		if status.status_name == name_to_check: return true
	
	return false

func _is_cc_resisted(new_status:Status) -> bool:
	if !new_status.is_crowd_control: return false
	
	if randi_range(0, 100) > stun_resistance: return false
	
	return true

func add_status(new_status:Status) -> void:
	if _is_cc_resisted(new_status): return
	
	var array_to_apply:Array[Status] = buffs
	var status_effect:GenericBuff
	
	if new_status.status_type == Status.STATUS_TYPE.DEBUFF:
		array_to_apply = debuffs
		status_effect = GENERIC_DEBUFF_EFFECT.instantiate()
	else:
		status_effect = GENERIC_BUFF_EFFECT.instantiate()
	
	status_effect.set_color(new_status.status_color)
	gchar.add_child(status_effect)
	
	if new_status.unique: _remove_same_status(array_to_apply, new_status)
	
	new_status.remove_status.connect(_remove_status.bind(new_status))
	new_status.connect_status(gchar)
	
	for affix:Affix in new_status.affixes:
		gchar.stat_handler.update_stat(affix.type_increase, affix.increase_amount)

	array_to_apply.push_back(new_status)
	if new_status.is_crowd_control: stun_resistance += STUN_RESISTANCE_PER_STUN
	GlobalSignals.show_floating_text.emit(new_status.status_name, gchar, new_status.status_color)
	status_added.emit(new_status)
	new_status.on_status_added()

func _remove_same_status(status_array:Array[Status], new_status:Status) -> void:
	var remove_array := status_array.duplicate().filter(func(status:Status): return status.status_name == new_status.status_name)
	if remove_array.is_empty(): return
	
	var status_to_remove:Status = remove_array[0]
	_remove_status(status_to_remove)

func _remove_status(status_to_remove:Status) -> void:
	status_to_remove.remove_status.disconnect(_remove_status)
	for affix:Affix in status_to_remove.affixes:
		gchar.stat_handler.update_stat(-affix.increase_amount, affix.type_increase)
	
	if buffs.has(status_to_remove):
		buffs.erase(status_to_remove)
	else: debuffs.erase(status_to_remove)
	
	status_to_remove.on_status_removed()
