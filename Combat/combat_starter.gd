extends Node3D
class_name CombatStarter

@export var combatants:Array[GameCharacter] = []
@export var area_3d:Area3D = null

func _start_combat_with_combatants() -> void:
	var combat_manager:CombatManager = GlobalSignals.combat_manager
	if !combatants.has(get_parent_node_3d()): combatants.push_back(get_parent_node_3d())
	combat_manager.start_combat(combatants)
	
	disable_group_combat_starters()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Player: return
	_start_combat_with_combatants()

func disable_combat_starter() -> void:
	area_3d.body_entered.disconnect(_on_area_3d_body_entered)
	queue_free()
	
func disable_group_combat_starters() -> void:
	for combatant:GameCharacter in combatants:
		for node in combatant.get_children():
			if node is CombatStarter: node.disable_combat_starter()
