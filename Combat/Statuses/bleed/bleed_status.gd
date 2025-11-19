extends Status
class_name BleedStatus

@export var bleed_sound:AudioStream = null

const BLOOD_EFFECT := preload("uid://cg47mkl168mib")

var bleed_per_movement:int = 0

#Overrided
func _connet_to_char_signals() -> void:
	affected_gchar.moved_to_tile.connect(_bleed)

func _bleed() -> void:
	var bleed_attack:Attack = Attack.new()
	bleed_attack.attacker = status_creator
	bleed_attack.set_tags([Ability.ABILITY_TAG.CANT_CRIT, Ability.ABILITY_TAG.DOT, Ability.ABILITY_TAG.UNEVADEABLE, Ability.ABILITY_TAG.NO_RETALIATION ])
	bleed_attack.damages = {Stats.DmgType.PURE: bleed_per_movement}
	
	AttackHandler.use_attack_on_char(affected_gchar, bleed_attack)
	GlobalSignals.play_audio.emit(bleed_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, affected_gchar.global_position)

	var blood_effect:Effect = BLOOD_EFFECT.instantiate()
	GlobalSignals.current_level.add_child(blood_effect)

func set_bleed_stats(dmg:int, duration:int) -> void:
	bleed_per_movement = dmg
	max_duration = duration
