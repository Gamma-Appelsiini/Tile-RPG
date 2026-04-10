extends Node
class_name OutlineHandler

enum OUTLINE_TYPE {ENEMY, FRIENDLY, NEUTRAL, OBJECT}

@export var mesh_to_outline:MeshInstance3D = null
@export var outline_type:OUTLINE_TYPE = OUTLINE_TYPE.OBJECT

const ENEMY_OUTLINE:ShaderMaterial = preload("uid://dqth8h8mfgfin")
const FRIENDLY_OUTLINE:ShaderMaterial = preload("uid://dixo86dkwapgy")
const NEUTRAL_OUTLINE:ShaderMaterial = preload("uid://uk4pc6755tq1")
const OBJECT_OUTLINE:ShaderMaterial = preload("uid://l0c1ypupcv43")
const OUTLINES:Dictionary[OUTLINE_TYPE, ShaderMaterial] = {
	OUTLINE_TYPE.ENEMY: ENEMY_OUTLINE,
	OUTLINE_TYPE.FRIENDLY: FRIENDLY_OUTLINE,
	OUTLINE_TYPE.NEUTRAL: NEUTRAL_OUTLINE,
	OUTLINE_TYPE.OBJECT: OBJECT_OUTLINE,}

const CHARACTER_TYPES:Array[OUTLINE_TYPE] = [OUTLINE_TYPE.ENEMY, OUTLINE_TYPE.FRIENDLY]
const CHARACTER_CIRCLE := preload("uid://m1q7emmmfpad")
const CIRCLE_MATERIALS:Dictionary[OUTLINE_TYPE, ShaderMaterial] = {
	OUTLINE_TYPE.ENEMY: preload("uid://b0umj4yqby8an"),
	OUTLINE_TYPE.FRIENDLY: preload("uid://d3jjo2h4hbf03"),
	}

var character_circle:MeshInstance3D = null
var outline_parent:GameCharacter = null
var node_hovered:bool = false
var show_outline_pressed:bool = false

func _ready() -> void:
	_connect_outline_signals()
	_add_char_circle()

func _node_hovered(hovered:bool) -> void:
	node_hovered = hovered
	if node_hovered or show_outline_pressed:
		GlobalSignals.mouse_hovered.emit(1)
		_show_outline()
	else:
		GlobalSignals.mouse_hovered.emit(-1)
		_hide_outline()
	
func _outline_pressed(pressed:bool) -> void:
	show_outline_pressed = pressed
	if node_hovered or show_outline_pressed: _show_outline()
	else: _hide_outline()

func _connect_outline_signals() -> void:
	GlobalSignals.show_outline.connect(_outline_pressed.bind(true))
	GlobalSignals.hide_outline.connect(_outline_pressed.bind(false))
	
	if get_parent().get_parent() is GameCharacter:
		outline_parent = get_parent().get_parent() as GameCharacter
		outline_parent.character_mouse_over.connect(_node_hovered.bind(true) )
		outline_parent.character_mouse_left.connect(_node_hovered.bind(false) )

func _add_char_circle() -> void:
	if !CHARACTER_TYPES.has(outline_type): return
	
	character_circle = CHARACTER_CIRCLE.instantiate()
	mesh_to_outline.add_child(character_circle)
	character_circle.hide()
	character_circle.material_override = CIRCLE_MATERIALS[outline_type]
	
	GlobalSignals.combat_start.connect(func(): character_circle.show())
	GlobalSignals.combat_end.connect(func(): character_circle.hide())

func _show_outline() -> void:
	var outline_material:ShaderMaterial = OUTLINES[outline_type]
	mesh_to_outline.material_overlay = outline_material

func _hide_outline() -> void:
	mesh_to_outline.material_overlay = null
