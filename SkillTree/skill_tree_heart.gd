extends Node3D
class_name SkillTreeHeart

@onready var skill_gem_amount_label_3d: Label3D = $SkillGemAmountLabel3D

func _ready() -> void:
	GlobalSignals.skill_gem_amount_changed.connect(set_skill_gem_amount)

func set_skill_gem_amount() -> void:
	skill_gem_amount_label_3d.text = str(GlobalSignals.ui_handler.inventory.player_skill_points)
