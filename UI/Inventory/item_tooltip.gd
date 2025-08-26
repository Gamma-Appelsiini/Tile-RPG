extends Control
class_name ItemTooltip

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var name_label: Label = %NameLabel
@onready var ilvl_label: Label = %IlvlLabel
@onready var affix_container: VBoxContainer = %AffixContainer
@onready var aff_label_template: Label = %AffLabelTemplate
@onready var implicit_label: Label = %ImplicitLabel
@onready var weapon_stats: VBoxContainer = %WeaponStats
@onready var price_label: Label = %PriceLabel
@onready var price_container: HBoxContainer = %PriceContainer
@onready var price_separator: HSeparator = %PriceSeparator
@onready var affix_separator: HSeparator = %AffixSeparator
@onready var tt_container: PanelContainer = %TTContainer

const WL_PATH:String = "res://Tile-RPG/UI/Inventory/weapon_line.tscn"

func get_tt_size() -> Vector2:
	return tt_container.size

func generate_tooltip(new_item:Item) -> void:
	name_label.text = new_item.item_name
	if new_item is Equipment: _equipment_handling(new_item as Equipment)
	
	if new_item is Armor: _armor_handling(new_item as Armor)
	elif new_item is Weapon: _weapon_handling(new_item as Weapon)
	
	_set_colors(new_item)
	_set_sell_price(new_item)
	
func _equipment_handling(new_equipment:Equipment) -> void:
	ilvl_label.visible = true
	
	var type_name:String = EnumStrings.SLOT_STRINGS[new_equipment.equipment_slot]
	var rariry_name:String = EnumStrings.RARITY_NAMES[new_equipment.item_rarity]
	ilvl_label.text = "Level " + str(new_equipment.item_level) + " " + rariry_name + " " + type_name
	
	if new_equipment.item_rarity == Item.ItemRarity.POOR: affix_separator.visible = false
	_add_affix_text(new_equipment)
	
func _armor_handling(new_armor:Armor) -> void:
	implicit_label.visible = true
	implicit_label.text = EnumStrings.DEF_NAMES[new_armor.defence_type] + ": " + str(new_armor.total_defence)
	implicit_label.add_theme_color_override("font_color",EnumStrings.DEF_COLORS[new_armor.defence_type])
	
func _weapon_handling(new_weapon:Weapon) -> void:
	var dmg_type:String = EnumStrings.DMG_TYPE_NAMES[new_weapon.damage_type] + " Damage: "
	var dmg_range:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.MIN_DMG]) + " - " + str(new_weapon.weapon_stats[Weapon.WeaponStat.MAX_DMG])
	var dmg_color:String = EnumStrings.RES_COLORS[new_weapon.damage_type]
	
	var range:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.RANGE])
	var crit_chance:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.BASE_CRIT])
	var crit_multi:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.BASE_MULTIPLIER])
	
	_add_weapon_stat_label(dmg_type, dmg_range,Color(dmg_color))
	_add_weapon_stat_label("Range: ",range)
	_add_weapon_stat_label("Crit Chance: ",crit_chance)
	_add_weapon_stat_label("Crit Multiplier: ",crit_multi)
	
func _add_weapon_stat_label(text1:String, text2:String,color_override:Color = Color("ffffff")) -> void:
	var new_line:WeaponLine = load(WL_PATH).instantiate()
	new_line.set_text(text1,text2,color_override)
	weapon_stats.add_child(new_line)

func _add_affix_text(new_equipment:Equipment) -> void:
	var new_name:String = new_equipment.item_name
	
	for pref:Affix in new_equipment.prefixes:
		new_name = pref.affix_name + " " + new_name
		_create_affix_line(pref)
		
	if len(new_equipment.suffixes) > 0: new_name += " of"
	for suf:Affix in new_equipment.suffixes:
		new_name = new_name + " "+ suf.affix_name
		_create_affix_line(suf)
		
	name_label.text = new_name

func _create_affix_line(aff:Affix) -> void:
		var new_label:Label = aff_label_template.duplicate()
		new_label.visible = true
		new_label.text = aff.affix_text
		affix_container.add_child(new_label)
		
func _set_colors(new_item:Item) -> void:
	var color_string:String = EnumStrings.RARITY_COLORS[new_item.item_rarity]
	name_label.add_theme_color_override("font_color",Color(color_string))
	
	var stylebox: StyleBoxFlat = tt_container.get_theme_stylebox("panel").duplicate()
	stylebox.border_color = Color(color_string)
	tt_container.add_theme_stylebox_override("panel", stylebox)

func _set_sell_price(new_item:Item) -> void:
	if 0 >= new_item.item_value: return
	
	price_separator.visible = true
	price_container.visible = true
	price_label.text = str(new_item.item_value)
