extends Node

const MAIN_STAT_NAMES := {
	Stats.MainStat.AGILITY: "Agility",
	Stats.MainStat.ENDURANCE: "Endurance",
	Stats.MainStat.LUCK: "Luck",
	Stats.MainStat.MIGHT: "Might",
	Stats.MainStat.MYSTIC: "Mystic",
	Stats.MainStat.SKILL: "Skill",
	Stats.MainStat.VALOR: "Valor",}

const MAIN_STAT_COLORS := {
	Stats.MainStat.AGILITY: "#2b722f",
	Stats.MainStat.ENDURANCE: "#ee5356",
	Stats.MainStat.LUCK: "#53bb81",
	Stats.MainStat.MIGHT: "#bd5136",
	Stats.MainStat.MYSTIC: "#8f39ee",
	Stats.MainStat.SKILL: "#f18690",
	Stats.MainStat.VALOR: "#d1b81b",}
	
const MAIN_STAT_PICS := {
	Stats.MainStat.AGILITY: "res://Tile-RPG/Images/Stats/agility.png",
	Stats.MainStat.ENDURANCE: "res://Tile-RPG/Images/Stats/endurance.png",
	Stats.MainStat.LUCK: "res://Tile-RPG/Images/Stats/luck.png",
	Stats.MainStat.MIGHT: "res://Tile-RPG/Images/Stats/might.png",
	Stats.MainStat.MYSTIC: "res://Tile-RPG/Images/Stats/mystic.png",
	Stats.MainStat.SKILL: "res://Tile-RPG/Images/Stats/skill.png",
	Stats.MainStat.VALOR: "res://Tile-RPG/Images/Stats/valor.png",}
	
const DEF_NAMES := {
	Stats.Defence.ARMOR: "Armor",
	Stats.Defence.EVASION: "Evasion",
	Stats.Defence.WARD: "Ward",
	Stats.Defence.BLOCK: "Block",
	Stats.Defence.SPELL_BLOCK: "Spell Block",
	Stats.Defence.DODGE: "Dodge",
	Stats.Defence.SPELL_DODGE: "Spell Dodge",
	Stats.Defence.GLANCE: "Glance"}
	
const SECONDARY_NAMES := {
	Stats.SecondaryStat.STOMACH_CAPACITY: "Stomach Capacity",
	Stats.SecondaryStat.ACCURACY: "Accuracy",
	Stats.SecondaryStat.BARTER: "Barter",
	Stats.SecondaryStat.GREED: "Greed",
	Stats.SecondaryStat.INITIATIVE: "Initiative",
	Stats.SecondaryStat.GLOBAL_CRIT_CHANCE: "Global Crit Chance",
	Stats.SecondaryStat.GLOBAL_CRIT_MULTIPLIER: "Global Crit Multiplier",
	Stats.SecondaryStat.SPELL_POWER: "Spell Power",
	Stats.SecondaryStat.SPELL_CRIT_CHANCE: "Spell Crit Chance",
	Stats.SecondaryStat.LIFE_ON_HIT: "Life On Hit",
	Stats.SecondaryStat.HEALTH_REGEN: "Health Regen",
	Stats.SecondaryStat.SPELL_RANGE: "Spell Range",
	Stats.SecondaryStat.BOW_RANGE: "Bow Range",
	Stats.SecondaryStat.SPELL_CRIT_MULTIPLIER: "Spell Crit Multiplier",
	Stats.SecondaryStat.ACCURACY_PERCENT: "Accuracy Percent",
	Stats.SecondaryStat.THORNS: "Thorns",
	Stats.SecondaryStat.SPELL_BASE_CRIT: "Spell Base Crit",
	}
	
const RES_COLORS := {
	Stats.DmgType.FIRE: "#dc3219",
	Stats.DmgType.FROST: "#87e1ff",
	Stats.DmgType.LIGHTNING: "#f0ff6e",
	Stats.DmgType.MYSTICAL: "#3c3cb9",
	Stats.DmgType.PHYSICAL: "#9ba5aa",
	Stats.DmgType.TOXIC: "#9637e6",
	Stats.DmgType.PURE: "#330809",
}

const RES_PICS := {
	Stats.DmgType.FIRE: "res://Tile-RPG/Images/Stats/fire.png",
	Stats.DmgType.FROST: "res://Tile-RPG/Images/Stats/ice.png",
	Stats.DmgType.LIGHTNING: "res://Tile-RPG/Images/Stats/lightning.png",
	Stats.DmgType.MYSTICAL: "res://Tile-RPG/Images/Stats/magic.png",
	Stats.DmgType.PHYSICAL: "res://Tile-RPG/Images/Stats/physical.png",
	Stats.DmgType.TOXIC: "res://Tile-RPG/Images/Stats/toxic.png",
}

const RES_NAMES := {
	Stats.DmgType.FIRE: "Fire",
	Stats.DmgType.FROST: "Frost",
	Stats.DmgType.LIGHTNING: "Lightning",
	Stats.DmgType.MYSTICAL: "Mystical",
	Stats.DmgType.PHYSICAL: "Physical",
	Stats.DmgType.TOXIC: "Toxic",
	Stats.DmgType.PURE: "Pure",
}

const DMG_TYPE_NAMES := {
	Stats.DmgIncreases.FIRE: "Fire",
	Stats.DmgIncreases.FROST: "Frost",
	Stats.DmgIncreases.LIGHTNING: "Lightning",
	Stats.DmgIncreases.MYSTICAL: "Mystical",
	Stats.DmgIncreases.PHYSICAL: "Physical",
	Stats.DmgIncreases.TOXIC: "Toxic",
	Stats.DmgIncreases.AXE: "Axe",
	Stats.DmgIncreases.SWORD: "Sword",
	Stats.DmgIncreases.BOW: "Bow",
	Stats.DmgIncreases.STAFF: "Staff",
	Stats.DmgIncreases.MACE: "Mace",
	Stats.DmgIncreases.DAGGER: "Dagger",
	Stats.DmgType.FIRE: "Fire",
	Stats.DmgType.FROST: "Frost",
	Stats.DmgType.LIGHTNING: "Lightning",
	Stats.DmgType.MYSTICAL: "Mystical",
	Stats.DmgType.PHYSICAL: "Physical",
	Stats.DmgType.TOXIC: "Toxic",
	
}

const STAT_TYPE_STRING := {
	Stats.MainStat: "main_stat",
	Stats.ResourceStat: "resource_stat",
	Stats.CharStat: "char_stat",
	Stats.SecondaryStat: "secondary_stat",
	Stats.SkillStat: "skill_stat",
	Stats.Defence: "defence",
	Stats.DmgType: "dmg_type",
	Stats.DmgIncreases: "dmg_increases",
}

const STRING_STAT_ENUM := {
	"main_stat": Stats.MainStat,
	"resource_stat": Stats.ResourceStat,
	"char_stat": Stats.CharStat,
	"secondary_stat": Stats.SecondaryStat,
	"skill_stat": Stats.SkillStat,
	"defence": Stats.Defence,
	"dmg_type": Stats.DmgType,
	"dmg_increases": Stats.DmgIncreases,
}

const RARITY_NAMES := {Item.ItemRarity.POOR : "Poor",
	Item.ItemRarity.COMMON: "Common",
	Item.ItemRarity.RARE: "Rare",
	Item.ItemRarity.EPIC: "Epic",
	Item.ItemRarity.LEGENDARY: "Legendary",
	Item.ItemRarity.GOD_ROLL: "God Roll",
	Item.ItemRarity.FABLED: "Fabled"}

const RARITY_COLORS := {Item.ItemRarity.POOR : "#d2d2d2",
	Item.ItemRarity.COMMON: "#32c346",
	Item.ItemRarity.RARE: "#1469e1",
	Item.ItemRarity.EPIC: "#6405fa",
	Item.ItemRarity.LEGENDARY: "#e17d00",
	Item.ItemRarity.GOD_ROLL: "#e00003",
	Item.ItemRarity.FABLED: "#915a14"}

const SLOT_STRINGS := {
	Equipment.EquipmentSlot.MAIN_HAND: "Weapon",
	Equipment.EquipmentSlot.OFF_HAND: "Off Hand",
	Equipment.EquipmentSlot.FEET: "Boots",
	Equipment.EquipmentSlot.HEAD: "Helmet",
	Equipment.EquipmentSlot.NECK: "Amulet",
	Equipment.EquipmentSlot.FINGER: "Ring",
	Equipment.EquipmentSlot.CHEST: "Body Armor",
	Equipment.EquipmentSlot.HANDS: "Gloves",
	Equipment.EquipmentSlot.WAIST: "Belt"
}

const DEF_COLORS := {
	Stats.Defence.ARMOR: "#b5b7ca",
	Stats.Defence.EVASION: "#64dea6",
	Stats.Defence.WARD: "#0ccaf8",
	Stats.Defence.BLOCK: "#e8bc6b",
	Stats.Defence.SPELL_BLOCK: "#e048f7",
	Stats.Defence.DODGE: "#38df68",
	Stats.Defence.SPELL_DODGE: "#ed6fbd",
	Stats.Defence.GLANCE: "#d0556c"}
	
