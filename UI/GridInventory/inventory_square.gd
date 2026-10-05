extends PanelContainer
class_name InventorySquare

@export var hover_image: TextureRect = null
@export var occupied_rect: TextureRect
@export var cant_place_rect: TextureRect

const SQUARE_SIZE:int = 50

var pos_x:int = 0
var pos_y:int = 0
var inv_item_in_square:InventoryItem = null

var occupied:bool = false:
	set(value):
		occupied = value
		if occupied: occupied_rect.show()
		else: occupied_rect.hide()

func _ready() -> void:
	custom_minimum_size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
	custom_maximum_size = Vector2(SQUARE_SIZE, SQUARE_SIZE)
	self.mouse_entered.connect(func(): hover_image.show())
	self.mouse_exited.connect(func(): hover_image.hide())
	
