extends Resource
class_name SkillResource

@export var skill_name:String = "Skill Name"
@export_multiline() var skill_description:String = "Skill Description"
@export var skill_stat_type:Stats.MainStat = Stats.MainStat.AGILITY
@export var skill_picture:Texture2D = null
@export var main_stat_increases:Dictionary[Stats.MainStat,int] = {}
@export var connected_to_tree_page:SkillTreeResource = null
@export var skills_in_tree_required_to_learn:int = 0

var learned:bool = false

func save_to_data(save_data:Dictionary) -> void:
	var skill_data:Dictionary[String, bool] = {
		"learned": learned
	}
	save_data["skills"][skill_name] = skill_data
	
func load_from_data(save_data:Dictionary) -> void:
	if !save_data["skills"].has(skill_name): return
	learned = save_data["skills"][skill_name]["learned"]
