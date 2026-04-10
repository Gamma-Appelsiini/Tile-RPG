extends Node
class_name MouseHandler

enum MOUSE_MODE {NORMAL, HOVER, CLICK, ERROR, TARGET}
enum MOUSE_STATE {NORMAL, TARGETING, MOUSE_DOWN}

const CURSOR_CLICKED := preload("uid://d36ramqb8c30t")
const CURSOR_ERROR := preload("uid://o4fbkpybq4lw")
const CURSOR_HOVER := preload("uid://pnegpg8aegex")
const CURSOR_NORMAL := preload("uid://odafl7spmr64")
const CURSOR_TARGETING := preload("uid://5tm50y4dnej6")

const MOUSE_ICONS:Dictionary[MOUSE_MODE, Texture2D] = {
	MOUSE_MODE.NORMAL: CURSOR_NORMAL,
	MOUSE_MODE.ERROR: CURSOR_ERROR,
	MOUSE_MODE.HOVER: CURSOR_HOVER,
	MOUSE_MODE.CLICK: CURSOR_CLICKED,
	MOUSE_MODE.TARGET: CURSOR_TARGETING,
	}

var hovered_amount:int = 0
var current_state:MOUSE_STATE = MOUSE_STATE.NORMAL
#TODO animated mouse cursor
var animated_sprite:AnimatedSprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if current_state == MOUSE_STATE.TARGETING: _set_mouse_state(MOUSE_STATE.NORMAL)
		else: _set_mouse_state(MOUSE_STATE.MOUSE_DOWN)
	elif event.is_action_released("Left Click"):
		_set_mouse_state(MOUSE_STATE.NORMAL)

func _set_hover_amount(amount:int) -> void:
	hovered_amount += amount

	if current_state == MOUSE_STATE.TARGETING or current_state == MOUSE_STATE.MOUSE_DOWN: return
	
	if hovered_amount == 0:
		if current_state != MOUSE_STATE.MOUSE_DOWN:
			_set_mouse_picture(MOUSE_MODE.NORMAL)
	else: _set_mouse_picture(MOUSE_MODE.HOVER)

func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	GlobalSignals.mouse_hovered.connect(_set_hover_amount)
	GlobalSignals.set_mouse_state.connect(_set_mouse_state)

func _set_mouse_picture(mouse_type:MOUSE_MODE) -> void:
	Input.set_custom_mouse_cursor(MOUSE_ICONS[mouse_type])
	
func _set_mouse_state(new_state:MOUSE_STATE) -> void:
	current_state = new_state
	
	if new_state == MOUSE_STATE.NORMAL:
		_set_hover_amount(0)
	elif new_state == MOUSE_STATE.MOUSE_DOWN:
		_set_mouse_picture(MOUSE_MODE.CLICK)
	elif new_state == MOUSE_STATE.TARGETING:
		_set_mouse_picture(MOUSE_MODE.TARGET)
