extends PanelContainer
class_name PictureContainer

@onready var level_label: Label = %LevelLabel
@onready var game_char_pic_rect: TextureRect = %GameCharPicRect
@onready var hp_prog_bar: ProgressBar = %HpProgBar

func set_info(gchar:GameCharacter) -> void:
	if gchar.picture: game_char_pic_rect.texture = gchar.picture
	level_label.text = "Level: " + str(gchar.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	hp_prog_bar.max_value = gchar.stat_handler.resources[Stats.ResourceStat.MAX_HP]
	hp_prog_bar.value = gchar.stat_handler.resources[Stats.ResourceStat.CURRENT_HP]
