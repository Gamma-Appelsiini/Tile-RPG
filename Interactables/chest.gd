extends Interactable
class_name LootContainer

enum ContainerStyle {WOOD}

@export var chest_lvl:int = -1
@export var max_tier:int = -1
@export var container_style:ContainerStyle = ContainerStyle.WOOD
@export var items_to_generate:Dictionary[Item.ItemRarity, ItemGenerator.LOOT_TYPE]
@export var container_name:String = "Chest"
@export var container_image:Texture2D = null
@export var animation_player:AnimationPlayer = null
@export var loot_beam:LootBeam = null

const OPEN_ANIM_NAME:String = "Open"
const CLOSE_ANIM_NAME:String = "Close"
const CONTAINER_SIZE:int = 10

var items:Array[Item] = []
var generated:bool = false

func interact() -> void:
	interact_area.monitoring = false
	_generate_loot()
	set_highest_rarity()
	GlobalSignals.close_container.connect(_close_container)
	
	loot_beam.show_beam()
	if animation_player:
		animation_player.play(OPEN_ANIM_NAME)
		await animation_player.animation_finished
	GlobalSignals.show_container.emit(self)
	
func _close_container(lootC:LootContainer) -> void:
	if lootC != self: return
	GlobalSignals.close_container.disconnect(_close_container)
	
	loot_beam.hide_beam()
	if animation_player:
		animation_player.play(CLOSE_ANIM_NAME)
		await animation_player.animation_finished
	interact_area.monitoring = true
	
func _generate_loot() -> void:
	if generated: return
	generated = true
	
	if chest_lvl == -1: chest_lvl = player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL]
	if max_tier == -1: max_tier = randi_range(0, player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	for rarity:Item.ItemRarity in items_to_generate.keys():
		var loot_type:ItemGenerator.LOOT_TYPE = items_to_generate[rarity]
		items.push_back(ItemGenerator.get_equipment(loot_type,chest_lvl,max_tier,rarity))

func set_highest_rarity() -> void:
	if len(items) == 0:
		loot_beam.hide_beam()
		return
	var highest_rarity:Item.ItemRarity = items[0].item_rarity
	
	for item:Item in items:
		if item.item_rarity > highest_rarity: highest_rarity = item.item_rarity
	
	loot_beam.set_rarity(highest_rarity)
	loot_beam.show_beam()

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
