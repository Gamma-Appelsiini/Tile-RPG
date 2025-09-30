extends Node3D
class_name LootBeam

@export var beam_mesh:MeshInstance3D = null
@export var scale_node:Node3D = null
@export var particles:GPUParticles3D = null

var end_scale:Vector3 = Vector3.ZERO

const MATERIALS:Dictionary[Item.ItemRarity,ShaderMaterial] = {
	Item.ItemRarity.POOR: preload("res://Tile-RPG/Effects/loot_beam/poor_material.tres"),
	Item.ItemRarity.COMMON: preload("res://Tile-RPG/Effects/loot_beam/common_material.tres"),
	Item.ItemRarity.RARE: preload("res://Tile-RPG/Effects/loot_beam/rare_material.tres"),
	Item.ItemRarity.EPIC: preload("res://Tile-RPG/Effects/loot_beam/epic_material.tres"),
	Item.ItemRarity.LEGENDARY: preload("res://Tile-RPG/Effects/loot_beam/legendary_material.tres"),
	Item.ItemRarity.GOD_ROLL: preload("res://Tile-RPG/Effects/loot_beam/godroll_material.tres"),
	Item.ItemRarity.FABLED: preload("res://Tile-RPG/Effects/loot_beam/fabled_material.tres"),}
const SCALES:Dictionary[Item.ItemRarity,float] = {
	Item.ItemRarity.POOR: 0.5,
	Item.ItemRarity.COMMON: 0.6,
	Item.ItemRarity.RARE: 0.7,
	Item.ItemRarity.EPIC: 0.8,
	Item.ItemRarity.LEGENDARY: 0.9,
	Item.ItemRarity.GOD_ROLL: 1,
	Item.ItemRarity.FABLED: 1.5,}
	
const PARTICLE_AMOUNTS:Dictionary[Item.ItemRarity,int] = {
	Item.ItemRarity.POOR: 2,
	Item.ItemRarity.COMMON: 3,
	Item.ItemRarity.RARE: 4,
	Item.ItemRarity.EPIC: 5,
	Item.ItemRarity.LEGENDARY: 6,
	Item.ItemRarity.GOD_ROLL: 7,
	Item.ItemRarity.FABLED: 8,}
	
const PARTICLE_COLORS:Dictionary[Item.ItemRarity,Color] = {
	Item.ItemRarity.POOR: Color("ffffff"),
	Item.ItemRarity.COMMON: Color("9cffb3"),
	Item.ItemRarity.RARE: Color(0.586, 0.923, 1.164),
	Item.ItemRarity.EPIC: Color(1.031, 0.686, 1.353),
	Item.ItemRarity.LEGENDARY: Color(1.398, 0.891, 0.0),
	Item.ItemRarity.GOD_ROLL: Color(1.587, 0.435, 0.487),
	Item.ItemRarity.FABLED: Color(1.587, 1.525, 0.533),}

func _init() -> void:
	self.visible = false
	scale_node.scale = Vector3(0.01,0.01,0.01)
	particles.emitting = false

func set_rarity(new_rarity:Item.ItemRarity) -> void:
	beam_mesh.material_override = MATERIALS[new_rarity]
	end_scale = Vector3(SCALES[new_rarity],SCALES[new_rarity],SCALES[new_rarity])
	particles.amount = PARTICLE_AMOUNTS[new_rarity]
	var material:ParticleProcessMaterial = particles.process_material
	material.color = PARTICLE_COLORS[new_rarity]

func show_beam() -> void:
	self.visible = true
	particles.emitting = true
	var tween:Tween = create_tween()
	tween.tween_property(scale_node, "scale", end_scale, 0.3).set_ease(Tween.EASE_IN)
	
