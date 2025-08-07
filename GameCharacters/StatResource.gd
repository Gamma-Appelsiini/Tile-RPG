extends Resource
class_name StatResource

@export var main_stats:Dictionary[Stats.MainStat,int] = {}
@export var skill_stats:Dictionary[Stats.SkillStat,int] = {}
@export var defences:Dictionary[Stats.Defence,int] = {}
@export var resources:Dictionary[Stats.ResourceStat,int] = {}
@export var secondary_stats:Dictionary[Stats.SecondaryStat,int] = {}
@export var resistances:Dictionary[Stats.DmgType,int] = {}
@export var dmg_increases:Dictionary[Stats.DmgIncreases,int] = {}
