extends Node

signal dialogue_signal(id:String)

var signal_funcs:Dictionary[String,Callable] ={
	"test": _test}

func _init() -> void:
	dialogue_signal.connect(_signal_received)

func _signal_received(signal_id:String) -> void:
	if signal_id in signal_funcs.keys():
		signal_funcs[signal_id].call()
	else:
		print("ERROR. NO ASSIGNED FUNCTION FOR SIGNAL ID: ", signal_id)

func _test() -> void:
	print("Test dialogue signal")

func add_signal_func(key:String, function:Callable) -> void:
	signal_funcs[key] = function
