class_name AttackHandler

const ARMOR_CURVE:Curve = null
const EVASION_CURVE:Curve = preload("uid://cwsdo8omrwkr7")
const MAX_BLOCK_CHANCE:int = 75
const MAX_EVADE_CHANCE:int = 75
const MAX_RES_PERCENT:int = 75
const MIN_HIT_CHANCE:int = 5

static var attack:Attack = null
static var receiver:GameCharacter = null
static var final_damage:int = 0

static func use_attack_on_char(new_receiver:GameCharacter, new_attack:Attack) -> void:
	final_damage = 0
	attack = new_attack
	receiver = new_receiver
	
	if !_does_attack_hit(): return
	
	_apply_damage_increases()
	attack.damages = _apply_resistances(attack.damages.duplicate())
	_apply_armor()
	_receive_damage()
	_handle_thorns()

static func _apply_damage_increases() -> void:
	for dmg_type:Stats.DmgType in attack.damages.keys():
		if dmg_type == Stats.DmgType.PURE: continue
		
		#Dmg increases keys are +50 compared to dmg types
		if attack.attacker.stat_handler.dmg_increases.has(dmg_type + 50):
			var damage_multiplier:float = 1.0 + (attack.attacker.stat_handler.dmg_increases[dmg_type + 50] / 100.0)
			print("Has increase: ", damage_multiplier)
			attack.damages[dmg_type] = int(attack.damages[dmg_type] * damage_multiplier )

static func _receive_damage() -> void:
	#TODO receiver hit animation
	receiver.got_hit.emit()
	GlobalSignals.show_damage_number.emit(final_damage, receiver, attack.crit)
	receiver.stat_handler.update_stat(Stats.ResourceStat.CURRENT_HP, final_damage)

static func _handle_thorns() -> void:
	if attack.tags.has(Attack.ATTACK_TAG.NO_RETALIATION): return
	var thorns_amount:int = receiver.stat_handler.secondary_stats[Stats.SecondaryStat.THORNS]
	if thorns_amount <= 0: return
	
	var thorns_attack:Attack = Attack.new()
	thorns_attack.attacker = receiver
	thorns_attack.tags.push_back(Attack.ATTACK_TAG.UNEVADEABLE)
	thorns_attack.tags.push_back(Attack.ATTACK_TAG.NO_RETALIATION)
	thorns_attack.damages[Stats.DmgType.PURE] = thorns_amount
	
	AttackHandler.use_attack_on_char(attack.attacker, thorns_attack)

static func _does_attack_hit() -> bool:
	if attack.tags.has(Attack.ATTACK_TAG.UNEVADEABLE): return true
	var hit_chance:int = 99
	
	var receiver_luck:int = receiver.stat_handler.main_stats[Stats.MainStat.LUCK]
	var attacker_luck:int = attack.attacker.stat_handler.main_stats[Stats.MainStat.LUCK]
	if attacker_luck > receiver_luck: hit_chance -= 4
	
	hit_chance -= _get_evasion_chance()
	if hit_chance < MIN_HIT_CHANCE: hit_chance = MIN_HIT_CHANCE
	print("Hit chance: ", hit_chance)
	
	if hit_chance < randi_range(1,100):
		receiver.stat_handler.attacks_dodged_in_a_row += 1
		receiver.dodged.emit()
		GlobalSignals.show_miss_text.emit("MISS", receiver)
		#TODO receiver evade animation
		return false
	
	#Block calc
	var blocked:bool = _is_attack_blocked()
	if blocked:
		GlobalSignals.show_miss_text.emit("BLOCKED", receiver)
		receiver.dodged.emit()
		_handle_thorns()
		#TODO receiver block animation
		return false
	
	receiver.stat_handler.attacks_dodged_in_a_row = 0
	return true

static func _get_evasion_chance() -> int:
	var attacker_accuracy_percent:int = attack.attacker.stat_handler.secondary_stats[Stats.SecondaryStat.ACCURACY_PERCENT]
	if attacker_accuracy_percent <= 0: attacker_accuracy_percent = 1
	var attacker_accuracy_multiplier:float = 1.0 + ( float(attacker_accuracy_percent) / 100)
	var attacker_accuracy:int = int(attack.attacker.stat_handler.secondary_stats[Stats.SecondaryStat.ACCURACY] * attacker_accuracy_multiplier)
	if attacker_accuracy <= 0: attacker_accuracy = 1

	var receiver_evasion:int = receiver.stat_handler.defences[Stats.Defence.EVASION]
	if receiver_evasion <= 0: receiver_evasion = 1
	var receiver_skill:int = receiver.stat_handler.main_stats[Stats.MainStat.SKILL]
	var attacker_skill:int = attack.attacker.stat_handler.main_stats[Stats.MainStat.SKILL]
	
	#Overskill evasion
	if attacker_skill > receiver_skill * 4: receiver_evasion /= 2
	
	var evasion_penetration:float = 1.0 - (attack.defence_penetrations[Stats.Defence.EVASION] / 100.0)
	receiver_evasion = int(receiver_evasion * evasion_penetration )
	
	var evade_entropy_multiplier:float = 1.0 + (0.25 * receiver.stat_handler.attacks_dodged_in_a_row)
	var end:float = receiver_evasion
	var point:float = (attacker_accuracy * evade_entropy_multiplier / end)
	if point > 1.0: point = 1.0
	var evasion_chance:float = EVASION_CURVE.sample(point)
	
	var dodge_chance:int = receiver.stat_handler.defences[Stats.Defence.DODGE]
	if attack.tags.has(Attack.ATTACK_TAG.SPELL): dodge_chance = receiver.stat_handler.defences[Stats.Defence.SPELL_DODGE]
	dodge_chance = dodge_chance - int(dodge_chance * (1.0 - evade_entropy_multiplier))
	if dodge_chance < 0: dodge_chance = 0
	
	var final_evasion_chance:int = int(evasion_chance * 100) + dodge_chance
	if final_evasion_chance > MAX_EVADE_CHANCE: final_evasion_chance = MAX_EVADE_CHANCE
	
	return final_evasion_chance

static func _is_attack_blocked() -> bool:
	var block_chance:int = receiver.stat_handler.defences[Stats.Defence.BLOCK]
	var block_reduction:int = attack.defence_penetrations[Stats.Defence.BLOCK]
	if attack.tags.has(Attack.ATTACK_TAG.SPELL):
		block_chance = receiver.stat_handler.defences[Stats.Defence.SPELL_BLOCK]
		block_reduction = attack.defence_penetrations[Stats.Defence.SPELL_BLOCK]
		
	if block_chance > MAX_BLOCK_CHANCE: block_chance = MAX_BLOCK_CHANCE
	
	var block_penetration:float = 1.0 - (block_reduction / 100.0)
	block_chance = int(block_chance * block_penetration )
	
	if block_chance >= randi_range(1,100): return true
	return false

#Resistance reduces damage up to 75%, negative values increase it
static func _apply_resistances(damages:Dictionary[Stats.DmgType,int]) -> Dictionary[Stats.DmgType,int]:
	for dmg_type in damages.keys():
		if dmg_type == Stats.DmgType.PURE: continue
		
		var res_amount:int = receiver.stat_handler.resistances[dmg_type]
		if res_amount > MAX_RES_PERCENT: res_amount = MAX_RES_PERCENT
		
		if res_amount > 0:
			#res pens enums are +100 values
			var res_penetration:float = 1.0 - (attack.attacker.stat_handler.resistance_penetrations[dmg_type + 100] / 100.0)
			res_amount = int(res_amount * res_penetration )
		
		if res_amount == 0: continue
		
		var dmg_multiplier:float = res_amount / 100.0
		if dmg_multiplier < 0: dmg_multiplier = abs(dmg_multiplier) + 1.0
		
		damages[dmg_type] = int(damages[dmg_type] * dmg_multiplier)
		if damages[dmg_type] <= 0: damages[dmg_type] = 1
	
	return damages

#TODO
static func _apply_armor() -> void:
	var pure_damage:int = 0
	for type:Stats.DmgType in attack.damages.keys():
		if type == Stats.DmgType.PURE:
			pure_damage += attack.damages[type]
			continue
		final_damage += attack.damages[type]
		
	if !attack.tags.has(Attack.ATTACK_TAG.HIT):
		final_damage += pure_damage
		return

	var receiver_armor:int = receiver.stat_handler.defences[Stats.Defence.ARMOR]
	var receiver_might:int = receiver.stat_handler.main_stats[Stats.MainStat.MIGHT]
	var attacker_might:int = attack.attacker.stat_handler.main_stats[Stats.MainStat.MIGHT]
	
	#Overpower armor
	if attacker_might > receiver_might * 4: receiver_armor /= 2
	
	var armor_penetration:float = 1.0 - (attack.defence_penetrations[Stats.Defence.ARMOR] / 100.0)
	receiver_armor = int(receiver_armor * armor_penetration )
	
	var point:float = receiver_armor / float((final_damage + pure_damage + receiver_armor) * 2)
	if point > 1.0: point = 1.0
	var reduction:float = ARMOR_CURVE.sample(point)
	print("Armor: ", receiver_armor, " Damage: ", final_damage + pure_damage, " Reduction: ", reduction)
	
	var reduced_damage:int = int(final_damage * reduction)
	if final_damage > 0 and reduced_damage <= 0: reduced_damage = 1
	
	final_damage = reduced_damage + pure_damage
