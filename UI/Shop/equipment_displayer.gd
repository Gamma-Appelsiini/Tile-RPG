extends Node3D
class_name EquipmentDisplayer

@export var rotation_node: Node3D = null
@export var sub_viewport: SubViewport = null

const OFFSETS:Dictionary[String, Vector3] = {"res://Tile-RPG/Items/ItemScenes/sword_model.tscn": Vector3(-0.025, -0.425, 0)}

var item_model:ItemModel = null

func _ready() -> void:
	const BASIC_SWORD := preload("uid://da0xr2nkj8xej")
	set_item_to_display(BASIC_SWORD)

func remove_model() -> void:
	if item_model == null: return
	item_model.queue_free()
	item_model = null

func set_item_to_display(new_item:Item) -> void:
	if new_item == null: return
	if new_item.item_model_path == "": return
	
	item_model = load(new_item.item_model_path).instantiate()
	item_model.visible = false
	rotation_node.add_child(item_model)
	
	item_model.item_mesh.set_layer_mask_value(1,false)
	item_model.item_mesh.set_layer_mask_value(16,true)
	
	if OFFSETS.has(new_item.item_model_path):
		item_model.position = OFFSETS[new_item.item_model_path]
		
	_rotate_model()

func _rotate_model() -> void:
	if item_model == null: return
	
	var tween:Tween = create_tween()
	tween.tween_property(rotation_node,"rotation:y", rotation_node.rotation.y + 360, 4)
	
	await tween.finished
	_rotate_model()
