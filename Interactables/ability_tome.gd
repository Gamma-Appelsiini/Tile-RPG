extends GroundDrop
class_name AbilityTome

@export var tome_model: ItemModel = null
@export var cover_mesh: MeshInstance3D = null
@export var stat_mesh: MeshInstance3D = null

var cover_material:StandardMaterial3D = null
var stat_material:StandardMaterial3D = null

func _ready() -> void:
	set_process(false)
	_set_inventory_ref()
	_on_creation()
	interact_area.monitoring = false
	
	cover_material = cover_mesh.material_override
	stat_material = stat_mesh.material_override

	_set_book_stat(Stats.MainStat.MIGHT)

func _set_book_stat(main_stat:Stats.MainStat) -> void:
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[main_stat])
	stat_material.albedo_texture = stat_texture
	
	cover_material.albedo_color = EnumStrings.MAIN_STAT_COLORS[Stats.MainStat.MIGHT]

func interact() -> void:
	var added:bool = player_inventory.add_item_to_inv(item_drop)
	if !added:
		GlobalSignals.play_audio.emit(loot_failed_sound, AudioManager.AUDIO_TYPE.UI, global_position)
		return
	
	GlobalSignals.play_audio.emit(loot_successful_sound, AudioManager.AUDIO_TYPE.UI,global_position)
	interact_area.monitoring = false
	item_model.visible = false
	loot_beam.hide_beam()
	
	await loot_beam.beam_hidden
	queue_free()

func set_item(new_item:Item) -> void:
	item_drop = new_item
	interact_text = new_item.item_name
	loot_beam.set_rarity(new_item.item_rarity)
	
	item_model = tome_model
