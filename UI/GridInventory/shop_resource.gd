extends Resource
class_name ShopResource

@export_category("Shop Stats")
@export var shop_name:String = "Name"
@export var shop_level:int = 1
@export var shop_portrait:Texture2D = null

@export_category("Flavor Texts")
@export_multiline() var FLAVOR_TEXT_BUY:Array[String] = ["Sold. For a good price.", "Good choice.", "I would have bought the same one myself."]
@export_multiline() var FLAVOR_TEXT_SELL:Array[String] = ["I'll take it off you.", "Where did you find this one?", "A common item."]
@export_multiline() var FLAVOR_TEXT_GOODBYE:Array[String] = ["Come back again.", "You're my best customer.", "Great deals here again tomorrow."]
@export_multiline() var FLAVOR_TEXT_WELCOME:Array[String] = ["Welcome to my shop.", "Good deals can be found here.", "Let me lighten your purse."]
