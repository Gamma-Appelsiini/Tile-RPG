extends Status
class_name EvasionBuff

func set_evasion_stats(evasion_amount:int, status_duration:int) -> void:
	self.max_duration = status_duration
	var new_affix:Affix = Affix.new()
	new_affix.increase_amount = evasion_amount
	new_affix.type_increase = Stats.Defence.EVASION
	affixes.push_back(new_affix)
