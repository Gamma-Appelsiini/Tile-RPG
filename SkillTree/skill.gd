extends Resource
class_name SkillResource

@export var skill_name:String = "Skill Name"
@export_multiline() var skill_description:String = "Skill Description"
@export var skill_stat_type:Stats.MainStat = Stats.MainStat.AGILITY
@export var skill_picture:Texture2D = null
@export var main_stat_increases:Dictionary[Stats.MainStat,int] = {}
@export var connected_to_tree_page:SkillTreeResource = null
