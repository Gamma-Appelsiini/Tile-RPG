extends Node3D
class_name AudioManager

enum AUDIO_TYPE {SOUND_EFFECT, MUSIC, UI, MASTER}

const AUDIO_BUSES:Dictionary[AUDIO_TYPE, String] = {
	AUDIO_TYPE.SOUND_EFFECT: "Sfx",
	AUDIO_TYPE.MUSIC: "Music",
	AUDIO_TYPE.UI: "Ui",
	AUDIO_TYPE.MASTER: "Master",
	}

var music_player:AudioStreamPlayer = null
var position_players:Array[AudioStreamPlayer3D] = []
var audio_player:AudioStreamPlayer


func _ready() -> void:
	GlobalSignals.play_audio.connect(play_audio)
	music_player = AudioStreamPlayer.new()
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.max_polyphony = 10
	
	GlobalSignals.change_volume.connect(_set_volume)
	
	var i:int = 0
	while 5 > i:
		var new_ap_3d := AudioStreamPlayer3D.new()
		position_players.push_back(new_ap_3d)
		add_child(new_ap_3d)
		i += 1

func _set_volume(audio_type:AUDIO_TYPE, amount:float) -> void:
	var bus_index:int = AudioServer.get_bus_index(AUDIO_BUSES[audio_type])
	var normalized_amount:float = amount / 100.0

	#logarithmic decibel scale
	var db_volume:float = linear_to_db(normalized_amount)
	AudioServer.set_bus_volume_db(bus_index, db_volume)
	#AudioServer.set_bus_mute(bus_index, amount <= 0)

func play_audio(new_stream:AudioStream, audio_type:AUDIO_TYPE, pos:Vector3 = Vector3.INF) -> void:
	if new_stream == null: return
	if pos != Vector3.INF:
		_play_3d_audio(new_stream,audio_type,pos)
		return
	
	audio_player.bus = AUDIO_BUSES[audio_type]
	audio_player.stream = new_stream
	audio_player.play()

func _play_3d_audio(new_stream:AudioStream, audio_type:AUDIO_TYPE, pos:Vector3) -> void:
	var free_player:AudioStreamPlayer3D = null
	for player:AudioStreamPlayer3D in position_players:
		if player.playing: continue
		free_player = player
	
	if free_player == null:
		free_player = AudioStreamPlayer3D.new()
		position_players.push_back(free_player)
		add_child(free_player)

	#if free_player.get_parent(): free_player.get_parent().remove_child(free_player)
	#GlobalSignals.current_level.add_child(free_player)
	
	free_player.bus = AUDIO_BUSES[audio_type]
	free_player.stream = new_stream
	free_player.global_position = pos
	free_player.play()
