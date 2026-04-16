extends ItemModel
class_name TomeModel

@export var tome_model: ItemModel = null
@export var cover_mesh: MeshInstance3D = null
@export var stat_mesh: MeshInstance3D = null

var cover_material:StandardMaterial3D = null
var stat_material:StandardMaterial3D = null

func _ready() -> void:
	collision_shape_3d.set_deferred("disabled", true)
	self.visible = false
	freeze = true
	
func set_book_stat(main_stat:Stats.MainStat) -> void:
	cover_material = cover_mesh.material_override
	stat_material = stat_mesh.material_override
	
	var stat_texture:Texture2D = load(EnumStrings.MAIN_STAT_PICS[main_stat])
	stat_material.albedo_texture = stat_texture
	
	cover_material.albedo_color = EnumStrings.MAIN_STAT_COLORS[main_stat]
