extends Node
class_name AttackInfoHandler

const ATTACK_INFO_PANEL := preload("uid://dkl5sg3sthut2")

var infos:Array[AttackInfoPanel] = []

func _ready() -> void:
	var i:int = 5
	while i > 0:
		var new_info:AttackInfoPanel = ATTACK_INFO_PANEL.instantiate()
		infos.push_back(new_info)
		add_child(new_info)
		i -= 1
		
func show_info_on_characters(chars:Array[GameCharacter], ability:Ability) -> void:
	while len(infos) < len(chars):
		var new_info:AttackInfoPanel = ATTACK_INFO_PANEL.instantiate()
		infos.push_back(new_info)
		add_child(new_info)
		
	for i:int in len(chars):
		infos[i].set_amounts(chars[i],ability)
		infos[i].show_info()

func hide_info() -> void:
	for info:AttackInfoPanel in infos:
		info.hide()
