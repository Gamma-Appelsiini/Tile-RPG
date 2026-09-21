extends PanelContainer
class_name SkillTooltip

signal skill_learned

@export var skill_name: Label = null
@export var skill_desc: Label = null
@export var skill_flavor: Label = null
@export var learn_label: Label = null
@export var progress_bar: ProgressBar = null
@export var skill_pic: TextureRect = null
@export var gpu_particles_2d: GPUParticles2D = null

var bar_tween:Tween = null
var skill_tree_sphere:SkillTreeSphere = null
var bar_enabled:bool = false

func _ready() -> void:
	if get_parent() is SkillTreeSphere: skill_tree_sphere = get_parent()

func _process(_delta: float) -> void:
	if progress_bar.value == 100:
		skill_learned.emit()
		reset_bar()
	
	if gpu_particles_2d.visible:
		gpu_particles_2d.global_position = progress_bar.global_position
		gpu_particles_2d.global_position.x += progress_bar.size.x * (progress_bar.value / 100)

func set_skill(new_skill:SkillResource) -> void:
	skill_desc.text = new_skill.skill_description
	skill_name.text = new_skill.skill_name
	skill_pic.texture = new_skill.skill_picture
	
	if new_skill.flavor_text != "":
		skill_flavor.text = new_skill.flavor_text
		skill_flavor.show()
	else: skill_flavor.hide()
	
	var color:Color = Color(EnumStrings.MAIN_STAT_COLORS[new_skill.skill_stat_type])
	var style_box = progress_bar.get_theme_stylebox("fill").duplicate()
	style_box.bg_color = color
	progress_bar.add_theme_stylebox_override("fill", style_box)
	
	_set_learn_label_text(new_skill)
	show()

func _skills_needed_to_learn(new_skill:SkillResource) -> int:
	return new_skill.skills_in_tree_required_to_learn - new_skill.tree_resource.amount_learned

func _set_learn_label_text(new_skill:SkillResource) -> void:
	bar_enabled = false
	
	if new_skill.learned:
		learn_label.text = "Learned"
	elif GlobalSignals.ui_handler.inventory.player_skill_points <= 0:
		learn_label.text = "Not enough Skill Points"
	elif _skills_needed_to_learn(new_skill) > 0:
		learn_label.text = str(_skills_needed_to_learn(new_skill)) + " more Skills in current tree required to learn"
	else:
		bar_enabled = true
		learn_label.text = "Hold M1 to learn"

func reset_bar() -> void:
	if bar_tween: bar_tween.kill()
	progress_bar.value = 0
	gpu_particles_2d.emitting = false
	gpu_particles_2d.hide()

func tween_load_bar() -> void:
	if !bar_enabled: return
	reset_bar()
	
	gpu_particles_2d.show()
	gpu_particles_2d.restart()
	gpu_particles_2d.emitting = true
	bar_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	bar_tween.tween_property(progress_bar, "value", 100, 1.5)
	
func set_screen_position(skill_orb:SkillOrb) -> void:
	var current_camera: Camera3D = get_viewport().get_camera_3d()
	if !current_camera:
		return

	var screen_position: Vector2 = current_camera.unproject_position(
		skill_orb.global_transform.origin
	)

	var offset := Vector2(-size.x / 2.0, -size.y + -45)
	var final_position := screen_position + offset
	var viewport_size := get_viewport_rect().size

	final_position.x = clamp(final_position.x, 0.0, viewport_size.x - size.x)
	final_position.y = clamp(final_position.y, 0.0, viewport_size.y - size.y)

	global_position = final_position
