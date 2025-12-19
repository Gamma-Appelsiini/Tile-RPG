extends PanelContainer
class_name GlobePanel

enum GlobeType {HEALTH, SPIRIT}

const BORDERS_DICT:Dictionary = {GlobeType.HEALTH: preload("uid://brpq8xv51lm25"), GlobeType.SPIRIT: preload("uid://cmse61kphiqjb")}

@export var globe_type:GlobeType = GlobeType.HEALTH
@export var borders: TextureRect = null
@export var viewport_rect: TextureRect = null

func _ready() -> void:
	borders.texture = BORDERS_DICT[globe_type]
