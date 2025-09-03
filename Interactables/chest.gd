extends Interactable
class_name LootContainer

@export var chest_lvl:int = -1
@export var max_tier:int = -1
@export var items_to_generate:Dictionary[Item.ItemRarity, ItemGenerator.LOOT_TYPE]
@export var container_name:String = "Chest"
@export var container_image:Texture2D = null

var items:Array[Item] = []
var generated:bool = false

func interact() -> void:
	_generate_loot()
	GlobalSignals.show_container.emit(self)
	
func _generate_loot() -> void:
	if generated: return
	generated = true
	
	if chest_lvl == -1: chest_lvl = player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL]
	if max_tier == -1: max_tier = randi_range(0, player.stat_handler.char_stats[Stats.CharStat.CURRENT_LEVEL])
	
	for rarity:Item.ItemRarity in items_to_generate.keys():
		print("generated item")
		var loot_type:ItemGenerator.LOOT_TYPE = items_to_generate[rarity]
		items.push_back(ItemGenerator.get_equipment(loot_type,chest_lvl,max_tier,rarity))
