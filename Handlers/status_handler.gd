extends Node
class_name StatusHandler

var buffs:Array[Status] = []
var debuffs:Array[Status] = []
var gchar:GameCharacter = null
const BLEED_STATUS = preload("uid://cfxrle4miamtb")

func _ready() -> void:
	if get_parent() is GameCharacter: gchar = get_parent()
	await get_tree().create_timer(1).timeout
	var bl:BleedStatus = BLEED_STATUS.instantiate()
	bl.set_bleed_stats(1,2)
	add_status(bl)
	
func add_status(new_status:Status) -> void:
	var array_to_apply:Array[Status] = buffs
	if new_status.status_type == Status.STATUS_TYPE.DEBUFF: array_to_apply = debuffs
	if new_status.unique: _remove_same_status(array_to_apply, new_status)
	
	new_status.remove_status.connect(_remove_status.bind(new_status))
	new_status.connect_status(gchar)
	
	for affix:Affix in new_status.affixes:
		gchar.stat_handler.update_stat(affix.increase_amount, affix.type_increase)

	array_to_apply.push_back(new_status)
	print("added status ", new_status.status_name, " to ", gchar.display_name)


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
	
	status_to_remove.queue_free()
	print("removed status ", status_to_remove.status_name)
