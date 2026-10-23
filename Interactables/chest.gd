extends Interactable
class_name LootContainer

@export_category("Loot Generation")
@export var chest_lvl:int = -1
@export var max_tier:int = -1
@export var items_to_generate:Dictionary[Item.ItemRarity, ItemGenerator.LOOT_TYPE]
@export var abilities_to_add:Array[String] = []

@export_category("Nodes")
@export var animation_player:AnimationPlayer = null
@export var shoot_position: Node3D
@export var shoot_target: Node3D
@export var gpu_particles_3d: GPUParticles3D

const OPEN_ANIM_NAME:String = "Open"
const CLOSE_ANIM_NAME:String = "Close"
const CONTAINER_SIZE:int = 10
const GROUND_DROP := preload("uid://cuocgxmrrsjwt")
const LOOT_GRADIENT:Gradient = preload("uid://l2qcvvkjwb5d")

var items:Array[Item] = []
var generated:bool = false

func interact() -> void:
	interact_area.monitoring = false
	_generate_loot()
	set_highest_rarity()
	gpu_particles_3d.emitting = true
	
	if animation_player:
		animation_player.play(OPEN_ANIM_NAME)
		await animation_player.animation_finished
	
	await _shoot_loot()
	interact_complete.emit()

func _shoot_loot() -> bool:
	for item:Item in items:
		var ground_drop:GroundDrop = GROUND_DROP.instantiate()
		ground_drop.set_item(item)
		GlobalSignals.current_level.add_child(ground_drop)
		ground_drop.global_position = shoot_position.global_position
		ground_drop.shoot_rigidbody(shoot_target.global_position, Vector2(1.5,2.5))
		await get_tree().create_timer(0.25).timeout
		
	return true

func _add_abilities() -> void:
	for path:String in abilities_to_add:
		_add_ability_tome(path)

func _add_ability_tome(path:String = "") -> void:
	if len(items) == CONTAINER_SIZE: return
	
	var new_tome:Tome = Tome.new()
	if path == "":
		path = AbilityGenerator.get_random_ability_path()
	new_tome.set_ability_path(path)

	items.push_back(new_tome)

func _generate_loot() -> void:
	if generated: return
	generated = true
	
	if chest_lvl == -1: chest_lvl = player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL]
	if max_tier == -1: max_tier = randi_range(0, player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	for rarity:Item.ItemRarity in items_to_generate.keys():
		var loot_type:ItemGenerator.LOOT_TYPE = items_to_generate[rarity]
		
		if loot_type == ItemGenerator.LOOT_TYPE.GOLD: items.push_back(ItemGenerator.get_money())
		elif loot_type == ItemGenerator.LOOT_TYPE.TOME: _add_ability_tome()
		else: items.push_back(ItemGenerator.get_equipment(loot_type,chest_lvl,max_tier,rarity))
	
	_add_abilities()

func set_highest_rarity() -> void:
	if len(items) == 0: return
	var highest_rarity:Item.ItemRarity = items[0].item_rarity
	for item: Item in items:
		if item.item_rarity > highest_rarity:
			highest_rarity = item.item_rarity
	
	var rarity_color:Color = EnumStrings.RARITY_COLORS[highest_rarity]
	LOOT_GRADIENT.set_color(1, rarity_color)
	LOOT_GRADIENT.set_color(2, rarity_color)

	var material := gpu_particles_3d.process_material as ParticleProcessMaterial
	if material and material.color_ramp:
		var gradient: Gradient = material.color_ramp.gradient
		if gradient:
			gradient.set_color(1, rarity_color)
			gradient.set_color(2, rarity_color)
	
	for item:Item in items:
		if item.item_rarity > highest_rarity: highest_rarity = item.item_rarity
	

func add_item(item:Item) -> bool:
	if len(items) >= CONTAINER_SIZE: return false
	if items.has(item): return false
	items.push_back(item)
	return true

func remove_item(item:Item) -> void:
	items.erase(item)

func save_to_data(save_data:Dictionary) -> void:
	if unique_id == "": return
	
	var item_data:Array[Dictionary] = []
	for item:Item in items:
		item_data.push_back(item.save_to_data())
	
	var data:Dictionary = {
		"generated": generated,
		"items": item_data,
	}
	
	save_data[unique_id] = data
	
func load_from_data(save_data:Dictionary) -> void:
	if !save_data.has(unique_id): return
	
	generated = save_data[unique_id]["generated"]
	var loaded_items:Array[Item] = []
	
	for data:Dictionary in save_data[unique_id]["items"]:
		var script: Script = load(data["item_type"])
		var loaded_item:Item = script.new()
		loaded_item.load_from_data(data)
		loaded_items.push_back(loaded_item)
		
	items = loaded_items
