extends PanelContainer
class_name AbilitySlot

signal ability_hovered(slot:AbilitySlot)
signal ability_unhovered(slot:AbilitySlot)

@export var ability_icon_rect:TextureRect = null
@export var cooldown_rect: ColorRect = null
@export var cooldown_label: Label = null
@export var select_rect: TextureRect = null
@export var hover_audio:AudioStream = null

var ability_in_slot:Ability = null

func _ready() -> void:
	self.mouse_entered.connect(_mouse_entered)
	self.mouse_exited.connect(_mouse_left)

func set_ability(new_ability:Ability) -> void:
	new_ability.cooldown_changed.connect(_set_cooldown)
	ability_icon_rect.texture = new_ability.ability_icon
	ability_icon_rect.visible = true
	ability_in_slot = new_ability

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
	select_rect.visible = true
	GlobalSignals.play_audio.emit(hover_audio, AudioManager.AUDIO_TYPE.UI)
	ability_hovered.emit(self)
	
func _mouse_left() -> void:
	select_rect.visible = false
	ability_unhovered.emit(self)
