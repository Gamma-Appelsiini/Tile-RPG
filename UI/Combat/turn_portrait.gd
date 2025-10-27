extends VBoxContainer
class_name TurnPortrait

@export var portrait_rect: TextureRect = null
@export var hp_label: Label = null
@export var shadow_rect: ColorRect = null
@export var hp_rect: ColorRect = null

var gchar:GameCharacter = null

func set_character(new_character:GameCharacter) -> void:
	portrait_rect.texture = new_character.picture
	gchar = new_character
	_set_hp()
	gchar.stat_handler.stats_changed.connect(_set_hp)
	
func _set_hp() -> void:
	var cur_hp:int = gchar.stat_handler.resources[Stats.ResourceStat.CURRENT_HP]
	var max_hp:int = gchar.stat_handler.resources[Stats.ResourceStat.MAX_HP]
	var hp_text:String = str(cur_hp) + "/" + str(max_hp)
	hp_label.text = hp_text
	
	var percentage:float = cur_hp / float(max_hp)
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
