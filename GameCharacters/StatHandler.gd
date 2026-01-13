class_name StatHandler

signal stats_changed
signal leveled_up
signal resources_changed(sh:StatHandler)
signal owner_died
signal xp_changed()

const POINTS_PER_LVL:int = 3
const XP_INCREASE:float = 1.5
const LOW_HEALTH_TRESHOLD:float = 0.35

var attacks_dodged_in_a_row:int = 0

var main_stats:Dictionary[Stats.MainStat,int] = {
	Stats.MainStat.AGILITY: 1,
	Stats.MainStat.ENDURANCE: 1,
	Stats.MainStat.LUCK: 1,
	Stats.MainStat.MIGHT: 1,
	Stats.MainStat.MYSTIC: 1,
	Stats.MainStat.SKILL: 1,
	Stats.MainStat.VALOR: 1,
}

var char_stats:Dictionary[Stats.CharStat,int] = {
	Stats.CharStat.STATS_TO_ALLOCATE: 0,
	Stats.CharStat.CURRENT_XP: 0,
	Stats.CharStat.MAX_XP: 100,
	Stats.CharStat.CURRENT_LEVEL: 1
}

var skill_stats:Dictionary[Stats.SkillStat,int] = {
	Stats.SkillStat.INSIGHT: 1,
	Stats.SkillStat.VIGOR: 1,
	Stats.SkillStat.FOCUS: 1,
}

var defences:Dictionary[Stats.Defence,int] = {
	Stats.Defence.ARMOR: 0,
	Stats.Defence.EVASION: 0,
	Stats.Defence.WARD: 0,
	Stats.Defence.BLOCK: 0,
	Stats.Defence.SPELL_BLOCK: 0,
	Stats.Defence.GLANCE: 0,
	Stats.Defence.DODGE: 0,
	Stats.Defence.SPELL_DODGE: 0
}

var resources:Dictionary[Stats.ResourceStat,int] = {
	Stats.ResourceStat.CURRENT_HP: 5,
	Stats.ResourceStat.CURRENT_AP: 0,
	Stats.ResourceStat.CURRENT_SPIRIT: 1,
	Stats.ResourceStat.CURRENT_MOVEMENT: 0,
	Stats.ResourceStat.MAX_HP: 5,
	Stats.ResourceStat.MAX_AP: 6,
	Stats.ResourceStat.MAX_SPIRIT: 1,
	Stats.ResourceStat.MAX_MOVEMENT: 7,
	Stats.ResourceStat.MOVEMENT_PER_TURN: 4,
	Stats.ResourceStat.AP_PER_TURN: 4,
}

var secondary_stats:Dictionary[Stats.SecondaryStat,int] = {}
var resistances:Dictionary[Stats.DmgType,int] = {}
var dmg_increases:Dictionary[Stats.DmgIncreases,int] = {}
var resistance_penetrations:Dictionary[Stats.DmgType,int] = {}

func _init() -> void:
	GlobalSignals.combat_start.connect(_on_combat_start)
	
	for stat in Stats.SecondaryStat.values():
		secondary_stats[stat] = 0
	for stat in Stats.DmgType.values():
		resistances[stat] = 0
	for stat in Stats.DmgIncreases.values():
		dmg_increases[stat] = 0
	for stat in Stats.ResPenetrations.values():
		resistance_penetrations[stat] = 0

func _on_combat_start() -> void:
	resources[Stats.ResourceStat.CURRENT_AP] = 0
	resources[Stats.ResourceStat.CURRENT_MOVEMENT] = 0
	
func on_turn_start() -> void:
	update_stat(Stats.ResourceStat.CURRENT_MOVEMENT, resources[Stats.ResourceStat.MOVEMENT_PER_TURN])
	update_stat(Stats.ResourceStat.CURRENT_AP, resources[Stats.ResourceStat.AP_PER_TURN])

func add_xp(amount:int) -> void:
	char_stats[Stats.CharStat.CURRENT_XP] += amount
	if char_stats[Stats.CharStat.CURRENT_XP] >= char_stats[Stats.CharStat.MAX_XP]:
		level_up()
	xp_changed.emit(char_stats[Stats.CharStat.CURRENT_XP], char_stats[Stats.CharStat.MAX_XP])

func level_up() -> void:
	char_stats[Stats.CharStat.CURRENT_XP] = char_stats[Stats.CharStat.CURRENT_XP] - char_stats[Stats.CharStat.MAX_XP]
	char_stats[Stats.CharStat.MAX_XP] = int(char_stats[Stats.CharStat.MAX_XP] * XP_INCREASE)
	char_stats[Stats.CharStat.CURRENT_LEVEL] += 1
	char_stats[Stats.CharStat.STATS_TO_ALLOCATE] += POINTS_PER_LVL
	#leveled_up.emit()
	stats_changed.emit()
	
	if char_stats[Stats.CharStat.CURRENT_XP] >= char_stats[Stats.CharStat.MAX_XP]:
		level_up()
	
func update_main_stat(main_stat:Stats.MainStat, amount:int) -> void:
	main_stats[main_stat] += amount
	#Might = armor, physical dmg, crit dmg
	if main_stat == Stats.MainStat.MIGHT:
		defences[Stats.Defence.ARMOR] += 2 * amount
		dmg_increases[Stats.DmgIncreases.PHYSICAL] += 2 * amount
		secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_MULTIPLIER] += 2 * amount
	#Agility = evasion, toxic dmg, initiative
	elif main_stat == Stats.MainStat.AGILITY:
		defences[Stats.Defence.EVASION] += 2 * amount
		dmg_increases[Stats.DmgIncreases.TOXIC] += 2 * amount
		secondary_stats[Stats.SecondaryStat.INITIATIVE] += 1 * amount
	#Endurace = hp, vigor
	elif main_stat == Stats.MainStat.ENDURANCE:
		resources[Stats.ResourceStat.MAX_HP] += 2 * amount
		resources[Stats.ResourceStat.CURRENT_HP] += 2 * amount
		skill_stats[Stats.SkillStat.VIGOR] += 1 * amount
	#Mystic = ward, mystical dmg, spell crit multi
	elif main_stat == Stats.MainStat.MYSTIC:
		defences[Stats.Defence.WARD] += 1 * amount
		dmg_increases[Stats.DmgIncreases.MYSTICAL] += 2 * amount
		secondary_stats[Stats.SecondaryStat.SPELL_CRIT_MULTIPLIER] += 2 * amount
	#Skill = focus, frost dmg, accuracy
	elif main_stat == Stats.MainStat.SKILL:
		skill_stats[Stats.SkillStat.FOCUS] += 1 * amount
		dmg_increases[Stats.DmgIncreases.FROST] += 2 * amount
		secondary_stats[Stats.SecondaryStat.ACCURACY] += 2 * amount
	#Luck = lightning dmg, crit chance, greed
	elif main_stat == Stats.MainStat.LUCK:
		secondary_stats[Stats.SecondaryStat.GREED] += 1 * amount
		dmg_increases[Stats.DmgIncreases.LIGHTNING] += 2 * amount
		secondary_stats[Stats.SecondaryStat.GLOBAL_CRIT_CHANCE] += 3 * amount
	#Valor = fire dmg, insight, spirit
	elif main_stat == Stats.MainStat.VALOR:
		skill_stats[Stats.SkillStat.INSIGHT] += 1 * amount
		dmg_increases[Stats.DmgIncreases.FIRE] += 2 * amount
		resources[Stats.ResourceStat.MAX_SPIRIT] += 1 * amount
		resources[Stats.ResourceStat.CURRENT_SPIRIT] += 1 * amount

func _update_current_hp(amount:int) -> void:
	resources[Stats.ResourceStat.CURRENT_HP] += amount
	
	if resources[Stats.ResourceStat.CURRENT_HP] > resources[Stats.ResourceStat.MAX_HP]:
		resources[Stats.ResourceStat.CURRENT_HP] = resources[Stats.ResourceStat.MAX_HP]
		
	resources_changed.emit(self)
	stats_changed.emit()
	
	if resources[Stats.ResourceStat.CURRENT_HP] <= 0:
		owner_died.emit()

func _update_resource_stat(type:int, amount:int) -> void:
	if type == Stats.ResourceStat.CURRENT_HP:
			_update_current_hp(amount)
			return
			
	self.resources[type] += amount
	if resources[Stats.ResourceStat.CURRENT_SPIRIT] > resources[Stats.ResourceStat.MAX_SPIRIT]:
		resources[Stats.ResourceStat.CURRENT_SPIRIT] = resources[Stats.ResourceStat.MAX_SPIRIT]
	
	if resources[Stats.ResourceStat.CURRENT_AP] > resources[Stats.ResourceStat.MAX_AP]:
		resources[Stats.ResourceStat.CURRENT_AP] = resources[Stats.ResourceStat.MAX_AP]
		
	if resources[Stats.ResourceStat.CURRENT_MOVEMENT] > resources[Stats.ResourceStat.MAX_MOVEMENT]:
		resources[Stats.ResourceStat.CURRENT_MOVEMENT] = resources[Stats.ResourceStat.MAX_MOVEMENT]
		
	resources_changed.emit(self)

func update_stat(type:int, amount:int) -> void:
	#TODO remove
	if type == Stats.MainStat.ENDURANCE: return
	
	if type in Stats.MainStat.values():
		self.update_main_stat(type,amount)
	elif type in Stats.SecondaryStat.values():
		self.secondary_stats[type] += amount
	elif type in Stats.CharStat.values():
		self.char_stats[type] += amount
	elif type in Stats.ResourceStat.values():
		_update_resource_stat(type, amount)
	elif type in Stats.DmgType.values():
		self.resistances[type] += amount
	elif type in Stats.DmgIncreases.values():
		self.dmg_increases[type] += amount
	elif type in Stats.Defence.values():
		self.defences[type] += amount
	elif type in Stats.SkillStat.values():
		self.skill_stats[type] += amount
	elif type in Stats.ResPenetrations.values():
		self.resistance_penetrations[type] += amount

	stats_changed.emit()

func get_stat_amount(type:int) -> int:
	var amount = 0
	
	if type in Stats.MainStat.values():
		amount = main_stats[type]
	elif type in Stats.SecondaryStat.values():
		amount = secondary_stats[type]
	elif type in Stats.CharStat.values():
		amount = char_stats[type]
	elif type in Stats.ResourceStat.values():
		amount = resources[type]
	elif type in Stats.DmgType.values():
		amount = resistances[type]
	elif type in Stats.DmgIncreases.values():
		amount = dmg_increases[type]
	elif type in Stats.Defence.values():
		amount = defences[type]
	elif type in Stats.SkillStat.values():
		amount = skill_stats[type]
	elif type in Stats.ResPenetrations.values():
		amount = resistance_penetrations[type]
	
	return amount

func save_to_data(save_data:Dictionary, unique_id:String) -> void:
	var sh_data := {
		EnumStrings.STAT_TYPE_STRING[Stats.MainStat]: main_stats.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.CharStat]: char_stats.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.SkillStat]: skill_stats.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.Defence]: defences.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.ResourceStat]: resources.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.SecondaryStat]: secondary_stats.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.DmgType]: resistances.duplicate(),
		EnumStrings.STAT_TYPE_STRING[Stats.DmgIncreases]: dmg_increases.duplicate(),
	}
	save_data["game_characters"][unique_id]["stat_handler"] = sh_data

func load_from_data(save_data:Dictionary, unique_id:String) -> void:
	var sh_data:Dictionary = save_data["game_characters"][unique_id]["stat_handler"]
	
	main_stats = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.MainStat]].duplicate()
	char_stats = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.CharStat]].duplicate()
	skill_stats = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.SkillStat]].duplicate()
	defences = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.Defence]].duplicate()
	resources = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.ResourceStat]].duplicate()
	secondary_stats = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.SecondaryStat]].duplicate()
	resistances = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.DmgType]].duplicate()
	dmg_increases = sh_data[EnumStrings.STAT_TYPE_STRING[Stats.DmgIncreases]].duplicate()
	
	stats_changed.emit()
	
func set_stats_from_resource(res:StatResource) -> void:
	for stat:int in res.main_stats:
		update_main_stat(stat,res.main_stats[stat])
		
	for stat:int in res.skill_stats:
		self.skill_stats[stat] = res.skill_stats[stat]
		
	for stat:int in res.defences:
		self.defences[stat] = res.defences[stat]
		
	for stat:int in res.resources:
		self.resources[stat] = res.resources[stat]
		
	for stat:int in res.secondary_stats:
		self.secondary_stats[stat] = res.secondary_stats[stat]
		
	for stat:int in res.resistances:
		self.resistances[stat] = res.resistances[stat]
		
	for stat:int in res.dmg_increases:
		self.dmg_increases[stat] = res.dmg_increases[stat]
	stats_changed.emit()

func is_on_low_health() -> bool:
	var health_percentage:float = get_stat_amount(Stats.ResourceStat.CURRENT_HP) / float(get_stat_amount(Stats.ResourceStat.MAX_HP))
	if health_percentage <= LOW_HEALTH_TRESHOLD: return true
	return false

func is_not_on_full_health() -> bool:
	if get_stat_amount(Stats.ResourceStat.CURRENT_HP) <= get_stat_amount(Stats.ResourceStat.MAX_HP): return true
	return false
