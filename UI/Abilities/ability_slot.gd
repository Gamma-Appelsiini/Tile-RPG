extends PanelContainer
class_name AbilitySlot

signal ability_hovered(slot:AbilitySlot)
signal ability_unhovered(slot:AbilitySlot)

const ABILITY_TOOLTIP := preload("uid://dwwbtybjbkw7p")

@export var ability_icon_rect:TextureRect = null
@export var cooldown_rect: ColorRect = null
@export var cooldown_label: Label = null
@export var select_rect: TextureRect = null
@export var hover_audio:AudioStream = null

var ability_in_slot:Ability = null
var tooltip:AbilityTooltip = null

func _ready() -> void:
	self.mouse_entered.connect(_mouse_entered)
	self.mouse_exited.connect(_mouse_left)

func set_ability(new_ability:Ability) -> void:
	new_ability.cooldown_changed.connect(_set_cooldown)
	ability_icon_rect.texture = new_ability.ability_icon
	ability_icon_rect.visible = true
	ability_in_slot = new_ability
	add_tooltip()

func add_tooltip() -> void:
	if tooltip: tooltip.queue_free()
	var new_tt:AbilityTooltip = ABILITY_TOOLTIP.instantiate()
	tooltip = new_tt
	new_tt.set_ability(ability_in_slot)
	new_tt.visible = false
	add_child(new_tt)


func _set_cooldown() -> void:
	cooldown_label.text = str(ability_in_slot.current_cooldown)
	if ability_in_slot.current_cooldown == 0:
		cooldown_label.visible = false
		cooldown_rect.visible = false
		return

	cooldown_label.visible = true
	cooldown_rect.visible = true

func remove_ability() -> void:
	ability_in_slot = null
	cooldown_label.visible = false
	cooldown_rect.visible = false
	ability_icon_rect.texture = null
	ability_icon_rect.visible = false

func _mouse_entered() -> void:
	_show_tt()
	
	select_rect.visible = true
	GlobalSignals.play_audio.emit(hover_audio, AudioManager.AUDIO_TYPE.UI)
	ability_hovered.emit(self)
	
func _mouse_left() -> void:
	if tooltip: tooltip.visible = false

	select_rect.visible = false
	ability_unhovered.emit(self)

func _show_tt():
	if !tooltip: return
	tooltip.visible = true
	
	var viewport_size:Vector2 = get_viewport_rect().size
	#var on_left:bool = (global_position.x + size.x * 0.5) < viewport_size.x * 0.5
	var offset_x:float = tooltip.panel_container.size.x
	var offset_y:float = (tooltip.panel_container.size.y - self.size.y) / 2

	tooltip.panel_container.global_position = self.global_position - Vector2(offset_x + 15, offset_y)
	
	var tt_bottom: float = tooltip.panel_container.global_position.y + tooltip.panel_container.size.y
	var tt_goes_outside_of_bottom_screen:bool = tt_bottom > viewport_size.y
	if tt_goes_outside_of_bottom_screen:
		tooltip.panel_container.global_position = self.global_position + Vector2(-(tooltip.panel_container.size.y / 2), -tooltip.panel_container.size.y)
