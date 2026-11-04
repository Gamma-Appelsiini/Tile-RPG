extends MarginContainer
class_name PortraitPanel

@export var name_label: Label
@export var lvl_label: Label
@export var game_char_pic_rect: TextureRect
@export var hp_prog_bar: ProgressBar
@export var hp_label: Label

var game_character:GameCharacter = null

func set_character(new_game_character:GameCharacter) -> void:
	game_character = new_game_character
	
	if game_character.picture: game_char_pic_rect.texture = game_character.picture
	name_label.text = game_character.display_name
	update_stats(new_game_character.stat_handler)

func update_stats(stat_handler:StatHandler) -> void:
	lvl_label.text = "Lvl " + str(stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	hp_prog_bar.max_value = stat_handler.resources[Stats.ResourceStat.MAX_HP]
	hp_prog_bar.value = stat_handler.resources[Stats.ResourceStat.CURRENT_HP]
	hp_label.text = str(stat_handler.resources[Stats.ResourceStat.CURRENT_HP]) + " / " + str(stat_handler.resources[Stats.ResourceStat.MAX_HP])
