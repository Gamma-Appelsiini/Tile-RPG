extends Node

var main_stat_names := {
	Stats.MainStat.AGILITY: "Agility",
	Stats.MainStat.ENDURANCE: "Endurance",
	Stats.MainStat.LUCK: "Luck",
	Stats.MainStat.MIGHT: "Might",
	Stats.MainStat.MYSTIC: "Mystic",
	Stats.MainStat.SKILL: "Skill",
	Stats.MainStat.VALOR: "Valor",}

var main_stat_colors := {
	Stats.MainStat.AGILITY: "#2b722f",
	Stats.MainStat.ENDURANCE: "#ee5356",
	Stats.MainStat.LUCK: "#53bb81",
	Stats.MainStat.MIGHT: "#bd5136",
	Stats.MainStat.MYSTIC: "#8f39ee",
	Stats.MainStat.SKILL: "#f18690",
	Stats.MainStat.VALOR: "#d1b81b",}
	
var def_names := {
	Stats.Defence.ARMOR: "Armor",
	Stats.Defence.EVASION: "Evasion",
	Stats.Defence.WARD: "Ward",
	Stats.Defence.BLOCK: "Block",
	Stats.Defence.SPELL_BLOCK: "Spell Block",
	Stats.Defence.DODGE: "Dodge",
	Stats.Defence.SPELL_DODGE: "Spell Dodge",
	Stats.Defence.GLANCE: "Glance"}
	
var res_colors := {
	Stats.DmgType.FIRE: "#dc3219",
	Stats.DmgType.FROST: "#87e1ff",
	Stats.DmgType.LIGHTNING: "#f0ff6e",
	Stats.DmgType.MYSTICAL: "#3c3cb9",
	Stats.DmgType.PHYSICAL: "#9ba5aa",
	Stats.DmgType.TOXIC: "#9637e6",
	Stats.DmgType.PURE: "#330809",
}

var res_names := {
	Stats.DmgType.FIRE: "Fire",
	Stats.DmgType.FROST: "Ice",
	Stats.DmgType.LIGHTNING: "Lightning",
	Stats.DmgType.MYSTICAL: "Magic",
	Stats.DmgType.PHYSICAL: "Physical",
	Stats.DmgType.TOXIC: "Toxic",
	Stats.DmgType.PURE: "Pure",
}

var dmg_type_names := {
	Stats.DmgIncreases.FIRE: "Fire",
	Stats.DmgIncreases.FROST: "Ice",
	Stats.DmgIncreases.LIGHTNING: "Lightning",
	Stats.DmgIncreases.MYSTICAL: "Magic",
	Stats.DmgIncreases.PHYSICAL: "Physical",
	Stats.DmgIncreases.TOXIC: "Toxic",
}

var stat_type_string := {
	Stats.MainStat: "main_stat",
	Stats.ResourceStat: "resource_stat",
	Stats.CharStat: "char_stat",
	Stats.SecondaryStat: "secondary_stat",
	Stats.SkillStat: "skill_stat",
	Stats.Defence: "defence",
	Stats.DmgType: "dmg_type",
	Stats.DmgIncreases: "dmg_increases",
}

var string_stat_enum := {
	"main_stat": Stats.MainStat,
	"resource_stat": Stats.ResourceStat,
	"char_stat": Stats.CharStat,
	"secondary_stat": Stats.SecondaryStat,
	"skill_stat": Stats.SkillStat,
	"defence": Stats.Defence,
	"dmg_type": Stats.DmgType,
	"dmg_increases": Stats.DmgIncreases,
}
