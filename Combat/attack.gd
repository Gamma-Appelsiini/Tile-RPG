class_name Attack

enum ATTACK_TAG {MELEE, RANGED, SPELL, AOE, SINGLE_TARGET, HIT, DOT, UNEVADEABLE}

var attacker:GameCharacter = null
var damages:Dictionary[Stats.DmgType,int] = {}
var tags: Array[ATTACK_TAG] = []
var crit:bool = false
