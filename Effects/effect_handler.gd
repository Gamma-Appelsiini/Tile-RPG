extends Node
class_name EffectHandler

const LEVEL_UP := preload("uid://binrcrkcfdfcs")

var gchar:GameCharacter = null

func _ready() -> void:
	if get_parent() is not GameCharacter: return
	gchar = get_parent()
	gchar.stat_handler.leveled_up.connect(_spawn_level_up_effect)
	
func _spawn_level_up_effect() -> void:
	var lvl_effect:Effect = LEVEL_UP.instantiate()
	gchar.add_child(lvl_effect)
	lvl_effect.play_effect()
