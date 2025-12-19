extends VBoxContainer
class_name TurnPortrait

enum BORDER_TYPE {ENEMY, FRIENDLY, PLAYER}

@export var portrait_rect: TextureRect = null
@export var hp_label: Label = null
@export var shadow_rect: ColorRect = null
@export var hp_rect: ColorRect = null
@export var panel_container: PanelContainer = null

const BORDER_COLORS:Dictionary[BORDER_TYPE, Color] ={
	BORDER_TYPE.ENEMY: Color(0.809, 0.0, 0.215, 1.0),
	BORDER_TYPE.FRIENDLY: Color(0.0, 0.61, 0.431, 1.0),
	BORDER_TYPE.PLAYER: Color(0.974, 0.851, 0.771, 1.0)}

var gchar:GameCharacter = null

func _ready() -> void:
	hp_rect.material = hp_rect.material.duplicate()

func set_character(new_character:GameCharacter, char_type:BORDER_TYPE = BORDER_TYPE.ENEMY) -> void:
	if new_character == null: return
	
	#portrait_rect.texture = new_character.picture
	gchar = new_character
	_set_border_color(char_type)
	_set_hp()
	gchar.stat_handler.stats_changed.connect(_set_hp)
	
func _set_border_color(type:BORDER_TYPE = BORDER_TYPE.ENEMY) -> void:
	panel_container.self_modulate = BORDER_COLORS[type]
	
func _set_hp() -> void:
	var cur_hp:int = gchar.stat_handler.resources[Stats.ResourceStat.CURRENT_HP]
	var max_hp:int = gchar.stat_handler.resources[Stats.ResourceStat.MAX_HP]
	var hp_text:String = str(cur_hp) + "/" + str(max_hp)
	hp_label.text = hp_text
	
	var percentage:float = cur_hp / float(max_hp)
	percentage = abs(1 - percentage)
	var shader_material:ShaderMaterial = hp_rect.material
	shader_material.set_shader_parameter("percentage", percentage)

func set_active() -> void:
	shadow_rect.visible = false
	
func set_deactive() -> void:
	shadow_rect.visible = true

func _on_turn_portrait_mouse_entered() -> void:
	hp_label.visible = true
	GlobalSignals.show_outline_on_target.emit(gchar)


func _on_turn_portrait_mouse_exited() -> void:
	hp_label.visible = false
	GlobalSignals.hide_outline_on_target.emit(gchar)
