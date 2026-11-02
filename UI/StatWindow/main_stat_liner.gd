extends MarginContainer
class_name MainStatLiner

@export var stat_pic: TextureRect
@export var stat_label: Label
@export var number_label: Label
@export var increase_stat_button: CloseButton

const STAT_ICON_MATERIAL := preload("uid://cb4rkkgxtauot")

var line_stat_type:Stats.MainStat = Stats.MainStat.AGILITY

func set_stat(stat_type:Stats.MainStat, amount:int) -> void:
	line_stat_type = stat_type
	stat_label.text = EnumStrings.MAIN_STAT_NAMES[stat_type]
	number_label.text = str(amount)
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[stat_type])
	stat_pic.texture = stat_texture
	
	var new_material:ShaderMaterial = STAT_ICON_MATERIAL.duplicate()
	stat_pic.material = new_material
	new_material.set_shader_parameter("stat_color", Color(EnumStrings.MAIN_STAT_COLORS[stat_type]))
	
	increase_stat_button.button.pressed.connect(_increase_player_stat)
		
func _increase_player_stat(stat_to_increase:Stats.MainStat = line_stat_type) -> void:
	var player:Player = GlobalSignals.player
	if player.stat_handler.get_stat_amount(Stats.CharStat.STATS_TO_ALLOCATE) == 0: return
	
	player.stat_handler.update_stat(Stats.CharStat.STATS_TO_ALLOCATE, -1)
	player.stat_handler.update_stat(stat_to_increase, 1)
