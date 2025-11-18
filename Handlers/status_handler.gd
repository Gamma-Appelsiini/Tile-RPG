extends Node
class_name StatusHandler

var buffs:Array[Status] = []
var debuffs:Array[Status] = []
var gchar:GameCharacter = null

func _ready() -> void:
	if get_parent() is GameCharacter: gchar = get_parent()
	
func add_status(new_status:Status) -> void:
	var array_to_apply:Array[Status] = buffs
	if new_status.status_type == Status.STATUS_TYPE.DEBUFF: array_to_apply = debuffs
	if new_status.unique: _remove_same_status(array_to_apply, new_status)
	
	new_status.remove_status.connect(_remove_status.bind(new_status))
	new_status.connect_status(gchar)
	
	for affix:Affix in new_status.affixes:
		gchar.stat_handler.update_stat(affix.increase_amount, affix.type_increase)

	array_to_apply.push_back(new_status)


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
	
	status_to_remove.free()
