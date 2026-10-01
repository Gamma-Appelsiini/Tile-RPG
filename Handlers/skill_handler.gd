extends Node
class_name SkillHandler

var learned_skills:Array[SkillResource] = []
var owner_character:GameCharacter = null

func _ready() -> void:
	if get_parent() is GameCharacter:
		owner_character = get_parent()
		owner_character.skill_handler = self

func add_skill(new_skill:SkillResource, loading:bool = false) -> void:
	learned_skills.push_back(new_skill)
	new_skill.owner_character = self.owner_character
	
	#Don't apply stats again when loading, they are saved in stat handler
	if loading: return
	
	for stat in new_skill.main_stat_increases.keys():
		owner_character.stat_handler.update_stat(stat, new_skill.main_stat_increases[stat])
	
func save_to_data(save_data:Dictionary) -> void:
	var skill_data:Array[String] = []
	
	for skill_resource:SkillResource in learned_skills:
		skill_data.push_back(skill_resource.resource_path)
	
	save_data["learned_skills"] = skill_data
	
func load_from_data(save_data:Dictionary) -> void:
	if !save_data.has("learned_skills"): return
	
	for resource_path:String in save_data["learned_skills"]:
		var new_skill:SkillResource = load(resource_path)
		add_skill(new_skill)
