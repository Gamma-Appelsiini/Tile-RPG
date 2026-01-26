extends Node3D
class_name LootBeam

signal beam_hidden

@export var beam_mesh:MeshInstance3D = null
@export var scale_node:Node3D = null
@export var beams: CPUParticles3D = null

const START_SCALE:Vector3 = Vector3(0.01,0.01,0.01)
const END_SCALE:Vector3 = Vector3(1,1,1)

const MATERIALS:Dictionary[Item.ItemRarity,ShaderMaterial] = {
	Item.ItemRarity.POOR: preload("res://Tile-RPG/Effects/loot_beam/poor_material.tres"),
	Item.ItemRarity.COMMON: preload("res://Tile-RPG/Effects/loot_beam/common_material.tres"),
	Item.ItemRarity.RARE: preload("res://Tile-RPG/Effects/loot_beam/rare_material.tres"),
	Item.ItemRarity.EPIC: preload("res://Tile-RPG/Effects/loot_beam/epic_material.tres"),
	Item.ItemRarity.LEGENDARY: preload("res://Tile-RPG/Effects/loot_beam/legendary_material.tres"),
	Item.ItemRarity.GOD_ROLL: preload("res://Tile-RPG/Effects/loot_beam/godroll_material.tres"),
	Item.ItemRarity.FABLED: preload("res://Tile-RPG/Effects/loot_beam/fabled_material.tres"),}
	
const PARTICLE_AMOUNTS:Dictionary[Item.ItemRarity,int] = {
	Item.ItemRarity.POOR: 1,
	Item.ItemRarity.COMMON: 2,
	Item.ItemRarity.RARE: 3,
	Item.ItemRarity.EPIC: 4,
	Item.ItemRarity.LEGENDARY: 5,
	Item.ItemRarity.GOD_ROLL: 6,
	Item.ItemRarity.FABLED: 7,}
	
const PARTICLE_COLORS:Dictionary[Item.ItemRarity,Color] = {
	Item.ItemRarity.POOR: Color("ffffff"),
	Item.ItemRarity.COMMON: Color("9cffb3"),
	Item.ItemRarity.RARE: Color(0.586, 0.923, 1.164),
	Item.ItemRarity.EPIC: Color(1.031, 0.686, 1.353),
	Item.ItemRarity.LEGENDARY: Color(1.398, 0.891, 0.0),
	Item.ItemRarity.GOD_ROLL: Color(1.587, 0.435, 0.487),
	Item.ItemRarity.FABLED: Color(1.587, 1.525, 0.533),}

func _ready() -> void:
	self.visible = false
	scale_node.scale = START_SCALE
	beams.emitting = false

func set_rarity(new_rarity:Item.ItemRarity) -> void:
	beam_mesh.material_override = MATERIALS[new_rarity]
	beams.amount = PARTICLE_AMOUNTS[new_rarity]
	
	if visible:
		var tween:Tween = create_tween()
		tween.tween_property(scale_node, "scale", END_SCALE, 0.2).set_ease(Tween.EASE_OUT)

func show_beam() -> void:
	if self.visible: return
	
	self.visible = true
	beams.emitting = true
	var tween:Tween = create_tween()
	tween.tween_property(scale_node, "scale", END_SCALE, 0.6).set_ease(Tween.EASE_IN_OUT)
	
func hide_beam() -> void:
	beams.emitting = false
	var tween:Tween = create_tween()
	tween.tween_property(scale_node, "scale", START_SCALE, 0.4).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	self.visible = false
	beam_hidden.emit()
