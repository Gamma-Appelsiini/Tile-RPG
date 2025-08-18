extends PanelContainer
class_name PictureContainer

@onready var level_label: Label = %LevelLabel
@onready var game_char_pic_rect: TextureRect = %GameCharPicRect
@onready var hp_prog_bar: ProgressBar = %HpProgBar
@onready var hp_label: Label = %HpLabel

func set_info(gchar:GameCharacter) -> void:
	if gchar.picture: game_char_pic_rect.texture = gchar.picture
	update_values(gchar.stat_handler)

func update_values(sh:StatHandler) -> void:
	level_label.text = "Level: " + str(sh.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	hp_prog_bar.max_value = sh.resources[Stats.ResourceStat.MAX_HP]
	hp_prog_bar.value = sh.resources[Stats.ResourceStat.CURRENT_HP]
	hp_label.text = str(sh.resources[Stats.ResourceStat.CURRENT_HP]) + " / " + str(sh.resources[Stats.ResourceStat.MAX_HP])
