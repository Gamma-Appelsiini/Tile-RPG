extends MarginContainer
class_name CharacterPanel

@export var portrait_panel: PortraitPanel
@export var main_stats_panel: MainStatsPanel
@export var skills_panel: SkillsPanel
@export var defences_panel: DefencesContainer
@export var resistances_panel: DefencesContainer
@export var close_red_button: CloseButton
@export var xp_prog_bar: ProgressBar
@export var xp_label: Label
@export var secondary_stats_panel: SecondaryStatsPanel
@export var reusable_button: ReusableButton

var stat_handler:StatHandler = null

func _ready() -> void:
	show()
	close_red_button.button.pressed.connect(hide)
	reusable_button.texture_button.pressed.connect(func(): secondary_stats_panel.visible = !secondary_stats_panel.visible)
	await get_tree().process_frame
	secondary_stats_panel.global_position = Vector2(self.global_position.x, reusable_button.global_position.y) + Vector2(self.size.x - 50, (reusable_button.size.y - secondary_stats_panel.size.y) / 2)
	hide()

func set_character(game_character:GameCharacter) -> void:
	stat_handler = game_character.stat_handler
	stat_handler.stats_changed.connect(_update_stats)
	
	portrait_panel.set_character(game_character)
	_update_stats()

func _update_stats() -> void:
	main_stats_panel.update_stats(stat_handler)
	skills_panel.update_stats(stat_handler)
	defences_panel.update_stats(stat_handler)
	resistances_panel.update_stats(stat_handler)
	portrait_panel.update_stats(stat_handler)
	
	xp_label.text = str(stat_handler.get_stat_amount(Stats.CharStat.CURRENT_XP)) + "/" + str(stat_handler.get_stat_amount(Stats.CharStat.MAX_XP))
	xp_prog_bar.max_value = stat_handler.get_stat_amount(Stats.CharStat.MAX_XP)
	xp_prog_bar.value = stat_handler.get_stat_amount(Stats.CharStat.CURRENT_XP)
