extends Interactable
class_name GroundDrop

@export var loot_beam:LootBeam = null
@export var highlight_material:ShaderMaterial = null
@export var loot_successful_sound:AudioStream = null
@export var loot_failed_sound:AudioStream = null
@export var parent_node:Node3D = null

var player_inventory:Inventory = null
var model_path:String = ""
var item_drop:Item = null
var item_model:ItemModel = null

func _ready() -> void:
	set_process(false)
	_set_inventory_ref()
	_on_creation()
	interact_area.monitoring = false

func _process(_delta: float) -> void:
	parent_node.global_position = item_model.global_position

func _set_inventory_ref() -> void:
	var UI := get_tree().get_nodes_in_group("UI")
	if UI[0] is UIHandler:
		var ui_handler:UIHandler = UI[0] as UIHandler
		player_inventory = ui_handler.inventory

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
	interact_text = "(" + get_input_string("Interact") + ") " + new_item.item_name
	loot_beam.set_rarity(new_item.item_rarity)
	
	if new_item.item_model_path != "":
		item_model = load(new_item.item_model_path).instantiate()
		item_model.visible = false
		add_child(item_model)

func shoot_rigidbody() -> void:
	set_process(true)
	item_model.item_mesh.material_overlay = highlight_material
	item_model.appear()
	
	var force:float = randf_range(5,8)
	var horizontal_dir := Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5)).normalized()
	var direction := (Vector3.UP + horizontal_dir * 0.1).normalized()
	
	item_model.apply_impulse(direction * force)
	await get_tree().create_timer(1).timeout
	loot_beam.show_beam()
	interact_area.monitoring = true
