extends Interactable
class_name MineableRock

@export var breakable_rocks:Breakable = null
@export var impact_sound:AudioStream = null
@export var crafting_gem: CraftingGemOrb = null

func interact() -> void:
	player.equipment_handler.show_pickaxe()
	
	await get_tree().create_timer(0.8).timeout
	GlobalSignals.play_audio.emit(impact_sound, AudioManager.AUDIO_TYPE.SOUND_EFFECT, self.global_position + Vector3(0,0.25,0))
	
	_explode_rocks()
	await get_tree().create_timer(0.4).timeout
	player.equipment_handler.hide_pickaxe()
	interact_complete.emit()

func _explode_rocks() -> void:
	var explode_origin:Vector3 = global_position + Vector3(0,0.25,0)
	breakable_rocks.explode_origin = explode_origin
	breakable_rocks._explode()
	
	crafting_gem.shoot_gem()
