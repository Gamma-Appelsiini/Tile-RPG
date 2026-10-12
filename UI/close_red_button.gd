extends PanelContainer
class_name CloseButton

@export var override_texture:Texture2D = null
@export var down_rect: TextureRect
@export var x_rect: TextureRect
@export var button: Button
@export var select_glow: TextureRect

func _ready() -> void:
	if override_texture: x_rect.texture = override_texture
	
	button.mouse_entered.connect(func(): select_glow.show())
	button.mouse_exited.connect(func(): select_glow.hide())
	button.button_down.connect(_on_press)
	button.button_up.connect(_on_release)
	
func _on_press() -> void:
	down_rect.show()
	x_rect.offset_transform_rotation = deg_to_rad(180)
	x_rect.self_modulate = Color("b3b3b3")
	x_rect.offset_transform_scale = Vector2(0.78,0.78)
	
func _on_release() -> void:
	down_rect.hide()
	x_rect.offset_transform_rotation = 0
	x_rect.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	x_rect.offset_transform_scale = Vector2(0.8,0.8)
