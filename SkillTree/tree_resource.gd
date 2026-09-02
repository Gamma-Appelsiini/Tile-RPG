extends Resource
class_name SkillTreeResource

@export var skills_in_tree:Dictionary[int, SkillResource] = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null,
	7: null,
}

func save_to_data(save_data:Dictionary) -> void:
	for skill_resource:SkillResource in skills_in_tree.values():
		if !skill_resource: continue
		skill_resource.save_to_data(save_data)
	
func load_from_data(save_data:Dictionary) -> void:
	if save_data == {}:
		print_debug("NO SAVE DATA FOR SKILLS")
		return
	for skill_resource:SkillResource in skills_in_tree.values():
		skill_resource.load_from_data(save_data)
