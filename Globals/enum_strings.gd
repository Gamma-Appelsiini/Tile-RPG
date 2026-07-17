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
	Stats.MainStat.VALOR: "#fece37ff",}
	
const MAIN_STAT_DESCRIPTIONS := {
	Stats.MainStat.AGILITY: "To be where they are not",
	Stats.MainStat.ENDURANCE: "The enduring will to bear the weight",
	Stats.MainStat.LUCK: "Some are more fortunate than others",
	Stats.MainStat.MIGHT: "Overpowering enemies",
	Stats.MainStat.MYSTIC: "Knowing the unseen",
	Stats.MainStat.SKILL: "The skilled always beat the ones who lack it",
	Stats.MainStat.VALOR: "Burn bright so others may see",}

const MAIN_STAT_SCALING := {
	Stats.MainStat.AGILITY: "+2 Evasion, +2% Tocic Dmg, +1 Initiative",
	Stats.MainStat.ENDURANCE: "+2 Max Hp, +0.5 Vigor",
	Stats.MainStat.LUCK: "+3 Global Crit Chance, +2% Lightning Dmg, +1 Greed",
	Stats.MainStat.MIGHT: "+2 Armor, +2% Physical Dmg, +2 Global Crit Multiplier",
	Stats.MainStat.MYSTIC: "+1 Ward, +2% Mystical Dmg, +2 Spell Crit Multiplier",
	Stats.MainStat.SKILL: "+2 Accuracy, +2% Frost Dmg, +0.5 Focus",
	Stats.MainStat.VALOR: "+1 Max Spirit, +2% Fire Dmg, +0.5 Insight",}

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

const SKILLS_PICS := {
	Stats.SkillStat.VIGOR: "res://Tile-RPG/Images/Stats/vigor.png",
	Stats.SkillStat.FOCUS: "res://Tile-RPG/Images/Stats/focus.png",
	Stats.SkillStat.INSIGHT: "res://Tile-RPG/Images/Stats/insight.png"
}

const SKILLS_COLORS := {
	Stats.SkillStat.VIGOR: "ff838c",
	Stats.SkillStat.FOCUS: "5effc0",
	Stats.SkillStat.INSIGHT: "8093ff"
}

const SKILLS_NAMES := {
	Stats.SkillStat.VIGOR: "Vigor",
	Stats.SkillStat.FOCUS: "Focus",
	Stats.SkillStat.INSIGHT: "Insight"
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
	Item.ItemRarity.RARE: "#49a6fbff",
	Item.ItemRarity.EPIC: "#7d63ffff",
	Item.ItemRarity.LEGENDARY: "#ffa353ff",
	Item.ItemRarity.GOD_ROLL: "#ff251cff",
	Item.ItemRarity.FABLED: "#d08527ff"}

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

const DEF_PICS := {
	Stats.Defence.ARMOR: "res://Tile-RPG/Images/Stats/armor.png",
	Stats.Defence.EVASION: "res://Tile-RPG/Images/Stats/evasion.png",
	Stats.Defence.WARD: "res://Tile-RPG/Images/Stats/ward.png",
	Stats.Defence.BLOCK: "res://Tile-RPG/Images/Stats/block.png",
	Stats.Defence.SPELL_BLOCK: "res://Tile-RPG/Images/Stats/spell_block.png",
	Stats.Defence.DODGE: "res://Tile-RPG/Images/Stats/dodge.png",
	Stats.Defence.SPELL_DODGE: "res://Tile-RPG/Images/Stats/spell_dodge.png",
	Stats.Defence.GLANCE: "res://Tile-RPG/Images/Stats/glance.png"}
