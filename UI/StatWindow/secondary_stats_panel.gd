extends PanelContainer
class_name SecondaryStatPanel

@onready var label: Label = %Label
@onready var v_box_container: VBoxContainer = %VBoxContainer

var stat_label_dict:Dictionary[Stats.SecondaryStat, Label] = {}

func _ready() -> void:
	_set_stats()
	GlobalSignals.connect("change_all_stats_visibility",_change_visibility)

func _set_stats() -> void:
	for stat:Stats.SecondaryStat in Stats.SecondaryStat.values():
		var new_label:Label = label.duplicate()
		print(EnumStrings.SECONDARY_NAMES[stat] + ": 0")
		new_label.text = EnumStrings.SECONDARY_NAMES[stat] + ": 0"
		stat_label_dict[stat] = new_label
		new_label.visible = true
		v_box_container.add_child(new_label)

func update_stats(sh:StatHandler) -> void:
	for stat:Stats.SecondaryStat in stat_label_dict.keys():
		stat_label_dict[stat].text = str(sh.secondary_stats[stat])

func _change_visibility() -> void:
	self.visible = !self.visible
