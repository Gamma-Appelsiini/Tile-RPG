extends Item
class_name GoldItem

const BUX_TEXTURE := preload("uid://ckinxcwmg4vsd")
const GOLD_MODEL_PATH:String = "res://Tile-RPG/Items/ItemScenes/gold_model.tscn"

const GOLD_AMOUNT_RARITIES:Dictionary[int, Item.ItemRarity] = {
	1: ItemRarity.POOR,
	20: ItemRarity.COMMON,
	40: ItemRarity.RARE,
	80: ItemRarity.EPIC,
	150: ItemRarity.LEGENDARY,
	500: ItemRarity.GOD_ROLL,
}

func _init() -> void:
	inventory_image = BUX_TEXTURE
	item_model_path = GOLD_MODEL_PATH

func set_gold_amount(amount:int = -1)  -> void:
	if amount == -1:
		item_value = ItemGenerator.get_money_drop_amount(GlobalSignals.player.stat_handler.get_stat_amount(Stats.CharStat.CURRENT_LEVEL))
	else: item_value = amount
	
	item_name = str(item_value) + " Bux"
	
	for treshold:int in GOLD_AMOUNT_RARITIES.keys():
		if item_value <= treshold:
			break
		item_rarity = GOLD_AMOUNT_RARITIES[treshold]
