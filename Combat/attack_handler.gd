class_name AttackHandler

static var attack:Attack = null
static var receiver:GameCharacter = null

const ARMOR_CURVE:Curve = null
const EVASION_CURVE:Curve = null
const MAX_BLOCK_CHANCE:int = 75

static func use_attack_on_char(new_receiver:GameCharacter, new_attack:Attack) -> void:
	attack = new_attack
	receiver = new_receiver
	
	if !_does_attack_hit(): return
	attack.damages = _apply_resistances(attack.damages.duplicate())

static func receive_damage() -> void:
	var dmg_amount:int = 0
	for amount:int in attack.damages.values():
		dmg_amount += amount
		
	GlobalSignals.show_damage_number.emit(dmg_amount, receiver, attack.crit)
	receiver.stat_handler.update_stat(Stats.ResourceStat.CURRENT_HP, dmg_amount)

static func _does_attack_hit() -> bool:
	var hit_chance:int = 99
	
	var receiver_luck:int = receiver.stat_handler.main_stats[Stats.MainStat.LUCK]
	var attacker_luck:int = attack.attacker.stat_handler.main_stats[Stats.MainStat.LUCK]
	if attacker_luck > receiver_luck: hit_chance -= 2
	
	var evasion_chance:int = _get_evasion_chance()
	hit_chance -= evasion_chance
	
	#Evasion calc
	if hit_chance < randi_range(1,100):
		GlobalSignals.show_miss_text.emit("MISS", receiver)
		#TODO receiver evade animation
		return false
	
	#Block calc
	var blocked:bool = _is_attack_blocked()
	if blocked:
		GlobalSignals.show_miss_text.emit("BLOCKED", receiver)
		#TODO receiver block animation
		return false
	
	return true

static func _get_evasion_chance() -> int:
	if attack.tags.has(Attack.ATTACK_TAG.UNEVADEABLE): return 0
	
	var receiver_evasion:int = receiver.stat_handler.defences[Stats.Defence.EVASION]
	var receiver_skill:int = receiver.stat_handler.main_stats[Stats.MainStat.SKILL]
	var attacker_skill:int = attack.attacker.stat_handler.main_stats[Stats.MainStat.SKILL]
	
	if attacker_skill * 5 > receiver_evasion: return 0
	
	var end:int = receiver_evasion
	var point:int = int(attacker_skill * 5.0 / end)
	point += attacker_skill - receiver_skill
	
	var evasion_chance:float = EVASION_CURVE.sample(point)
	return int(evasion_chance * 100)

static func _is_attack_blocked() -> bool:
	var block_chance:int = receiver.stat_handler.defences[Stats.Defence.BLOCK]
	if attack.tags.has(Attack.ATTACK_TAG.SPELL):
		block_chance = receiver.stat_handler.defences[Stats.Defence.SPELL_BLOCK]
		
	if block_chance > MAX_BLOCK_CHANCE: block_chance = MAX_BLOCK_CHANCE
	if block_chance >= randi_range(1,100): return true
	return false

#Resistance reduces damage up to 75%, negative values increase it
static func _apply_resistances(damages:Dictionary[Stats.DmgType,int]) -> Dictionary[Stats.DmgType,int]:
	for dmg_type in damages.keys():
		if dmg_type == Stats.DmgType.PURE: continue
		
		var res_amount:int = receiver.stat_handler.resistances[dmg_type]
		if res_amount > 75: res_amount = 75
		if res_amount == 0: continue
		
		var dmg_multiplier:float = res_amount / 100.0
		if dmg_multiplier < 0: dmg_multiplier = abs(dmg_multiplier) + 1.0
		
		damages[dmg_type] = int(damages[dmg_type] * dmg_multiplier)
		if damages[dmg_type] <= 0: damages[dmg_type] = 1
	
	return damages

#TODO
static func _apply_armor(damages:Dictionary[Stats.DmgType,int]) -> Dictionary[Stats.DmgType,int]:
	return damages
