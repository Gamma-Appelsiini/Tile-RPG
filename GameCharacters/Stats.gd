class_name Stats

#Has to be different enum number for affix checking
enum MainStat {
	AGILITY = 0,
	ENDURANCE,
	LUCK,
	MIGHT,
	MYSTIC,
	SKILL,
	VALOR
}

enum ResourceStat {
	MAX_HP = 50,
	CURRENT_HP,
	MAX_SPIRIT,
	CURRENT_SPIRIT,
	MAX_AP,
	CURRENT_AP,
	MAX_MOVEMENT,
	CURRENT_MOVEMENT,
}

enum CharStat {
	STATS_TO_ALLOCATE = 100,
	CURRENT_XP,
	MAX_XP,
	CURRENT_LEVEL
}

enum SecondaryStat {
	STOMACH_CAPACITY = 150,
	ACCURACY,
	BARTER,
	GREED,
	INITIATIVE,
	GLOBAL_CRIT_CHANCE,
	GLOBAL_CRIT_MULTIPLIER,
	SPELL_POWER,
	SPELL_CRIT_CHANCE,
	LIFE_ON_HIT,
	HEALTH_REGEN,
	SPELL_RANGE,
	BOW_RANGE,
	SPELL_CRIT_MULTIPLIER,
	ACCURACY_PERCENT,
	THORNS,
	SPELL_BASE_CRIT,
}

enum SkillStat {
	FOCUS = 250,
	INSIGHT,
	VIGOR
}

enum Defence {
	ARMOR = 300,
	EVASION,
	WARD,
	BLOCK,
	SPELL_BLOCK,
	DODGE,
	SPELL_DODGE,
	GLANCE
}

enum DmgType {
	PHYSICAL = 400,
	MYSTICAL,
	LIGHTNING,
	FIRE,
	FROST,
	TOXIC,
	PURE
}

enum DmgIncreases {
	PHYSICAL = 450,
	MYSTICAL,
	LIGHTNING,
	FIRE,
	FROST,
	TOXIC
}

var main_stat_colors = {
	MainStat.AGILITY: "#2b722f",
	MainStat.ENDURANCE: "#ee5356",
	MainStat.LUCK: "#53bb81",
	MainStat.MIGHT: "#bd5136",
	MainStat.MYSTIC: "#8f39ee",
	MainStat.SKILL: "#f18690",
	MainStat.VALOR: "#d1b81b",}
	
var def_names = {
	Defence.ARMOR: "Armor",
	Defence.EVASION: "Evasion",
	Defence.WARD: "Ward",
	Defence.BLOCK: "Block",
	Defence.SPELL_BLOCK: "Spell Block",
	Defence.DODGE: "Dodge",
	Defence.SPELL_DODGE: "Spell Dodge",
	Defence.GLANCE: "Glance"}
	
var res_colors = {
	DmgType.FIRE: "#dc3219",
	DmgType.FROST: "#87e1ff",
	DmgType.LIGHTNING: "#f0ff6e",
	DmgType.MYSTICAL: "#3c3cb9",
	DmgType.PHYSICAL: "#9ba5aa",
	DmgType.TOXIC: "#9637e6",
	DmgType.PURE: "#330809",
}

var res_names = {
	DmgType.FIRE: "Fire",
	DmgType.FROST: "Ice",
	DmgType.LIGHTNING: "Lightning",
	DmgType.MYSTICAL: "Magic",
	DmgType.PHYSICAL: "Physical",
	DmgType.TOXIC: "Toxic",
	DmgType.PURE: "Pure",
}

var dmg_type_names = {
	DmgIncreases.FIRE: "Fire",
	DmgIncreases.FROST: "Ice",
	DmgIncreases.LIGHTNING: "Lightning",
	DmgIncreases.MYSTICAL: "Magic",
	DmgIncreases.PHYSICAL: "Physical",
	DmgIncreases.TOXIC: "Toxic",
}
