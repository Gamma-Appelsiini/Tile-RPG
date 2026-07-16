extends Control
class_name ItemTooltip

@export var v_box_container: VBoxContainer
@export var name_label: Label
@export var ilvl_label: Label
@export var affix_container: VBoxContainer
@export var aff_label_template: Label
@export var implicit_label: Label
@export var weapon_stats: VBoxContainer
@export var price_label: Label
@export var price_container: HBoxContainer
@export var price_separator: TextureRect
@export var affix_separator: TextureRect
@export var tt_container: PanelContainer
@export var ability_rect: TextureRect = null
@export var gradient_rect: TextureRect = null

const WL_PATH:String = "res://Tile-RPG/UI/Inventory/weapon_line.tscn"

var gradient:GradientTexture2D = null

func _ready() -> void:
	gradient = gradient_rect.texture

func get_tt_size() -> Vector2:
	return tt_container.size

func _reset_tooltip() -> void:
	for line:WeaponLine in weapon_stats.get_children():
		line.hide()
		line.queue_free()
	for label:Label in affix_container.get_children():
		if label != aff_label_template:
			label.hide()
			label.queue_free()
	
	_reset_colors()
	
	ability_rect.hide()
	implicit_label.hide()
	ilvl_label.show()
	name_label.show()
	affix_separator.show()

func generate_tooltip(new_item:Item) -> void:
	_reset_tooltip()

	if new_item is Tome:
		_generate_tome_tooltip(new_item)
		return
	elif new_item is GoldItem:
		_generate_gold_tooltip(new_item)
		return
	
	name_label.text = new_item.item_name
	
	if new_item is Equipment: _equipment_handling(new_item as Equipment)
	
	if new_item is Armor: _armor_handling(new_item as Armor)
	elif new_item is Weapon: _weapon_handling(new_item as Weapon)
	
	_set_colors(new_item)
	_set_sell_price(new_item)

func _generate_gold_tooltip(_new_gold:GoldItem) -> void:
	affix_separator.hide()
	name_label.hide()
	ilvl_label.hide()

func _generate_tome_tooltip(new_tome:Tome) -> void:
	ilvl_label.text = new_tome.ability.ability_desc
	name_label.text = new_tome.item_name
	ability_rect.texture = new_tome.ability.ability_icon
	ability_rect.show()
	
	var stylebox: StyleBoxFlat = tt_container.get_theme_stylebox("panel")
	stylebox.border_color = Color(EnumStrings.MAIN_STAT_COLORS[new_tome.ability.ability_main_stat])

func _equipment_handling(new_equipment:Equipment) -> void:
	ilvl_label.visible = true
	
	var type_name:String = EnumStrings.SLOT_STRINGS[new_equipment.equipment_slot]
	var rariry_name:String = EnumStrings.RARITY_NAMES[new_equipment.item_rarity]
	
	if new_equipment is Weapon:
		var hand_text:String = "One Handed "
		if new_equipment.hand_type == Weapon.HandType.TWO_HANDED: hand_text = "Two Handed "
		ilvl_label.text = "Level " + str(new_equipment.item_level) + " " + rariry_name + " " + hand_text + type_name
	else: ilvl_label.text = "Level " + str(new_equipment.item_level) + " " + rariry_name + " " + type_name
	
	if new_equipment.item_rarity == Item.ItemRarity.POOR: affix_separator.visible = false
	else: affix_separator.visible = true
	_add_affix_text(new_equipment)
	
func _armor_handling(new_armor:Armor) -> void:
	implicit_label.visible = true
	implicit_label.text = EnumStrings.DEF_NAMES[new_armor.defence_type] + ": " + str(new_armor.total_defence)
	implicit_label.add_theme_color_override("font_color",EnumStrings.DEF_COLORS[new_armor.defence_type])
	
func _weapon_handling(new_weapon:Weapon) -> void:
	var dmg_type:String = EnumStrings.DMG_TYPE_NAMES[new_weapon.damage_type] + " Damage: "
	var dmg_range:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.MIN_DMG]) + " - " + str(new_weapon.weapon_stats[Weapon.WeaponStat.MAX_DMG])
	var dmg_color:String = EnumStrings.RES_COLORS[new_weapon.damage_type]
	
	var wep_range:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.RANGE])
	var crit_chance:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.BASE_CRIT])
	var crit_multi:String = str(new_weapon.weapon_stats[Weapon.WeaponStat.BASE_MULTIPLIER])
	var stat_scale:String = EnumStrings.MAIN_STAT_NAMES[new_weapon.scale_stat]
	var scale_amount:String = str(float(new_weapon.weapon_stats[Weapon.WeaponStat.SCALE_AMOUNT]) / 100)
	var stat_color:String = EnumStrings.MAIN_STAT_COLORS[new_weapon.scale_stat]
	
	_add_weapon_stat_label(dmg_type, dmg_range,Color(dmg_color))
	_add_weapon_stat_label("Range: ",wep_range)
	_add_weapon_stat_label("Crit Chance: ",crit_chance + "%")
	_add_weapon_stat_label("Crit Multiplier: ",crit_multi + "%")
	_add_weapon_stat_label("Scaling: ", scale_amount + "x", Color(stat_color))
	
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

func _reset_colors() -> void:
	name_label.remove_theme_color_override("font_color")
	var stylebox: StyleBoxFlat = tt_container.get_theme_stylebox("panel")
	stylebox.border_color = Color(EnumStrings.RARITY_COLORS[Item.ItemRarity.POOR])
	
func _set_colors(new_item:Item) -> void:
	var color_string:String = EnumStrings.RARITY_COLORS[new_item.item_rarity]
	name_label.add_theme_color_override("font_color",Color(color_string))
	gradient.gradient.set_color(1, Color(color_string))
	
	var stylebox: StyleBoxFlat = tt_container.get_theme_stylebox("panel")
	stylebox.border_color = Color(color_string)

func _set_sell_price(new_item:Item) -> void:
	if 0 >= new_item.item_value: return
	
	price_separator.visible = true
	price_container.visible = true
	price_label.text = str(new_item.item_value)
