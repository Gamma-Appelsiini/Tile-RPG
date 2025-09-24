extends Node3D
class_name AudioManager

enum AUDIO_TYPE {SOUND_EFFECT, MUSIC, UI}

var music_player:AudioStreamPlayer = null
var position_players:Array[AudioStreamPlayer3D] = []
var audio_player:AudioStreamPlayer

var volumes:Dictionary[AUDIO_TYPE, float] = {
	AUDIO_TYPE.SOUND_EFFECT: 1,
	AUDIO_TYPE.MUSIC: 1,
	AUDIO_TYPE.UI: 1,}

func _ready() -> void:
	GlobalSignals.play_audio.connect(play_audio)
	music_player = AudioStreamPlayer.new()
	volumes[AUDIO_TYPE.SOUND_EFFECT] = music_player.volume_linear
	volumes[AUDIO_TYPE.MUSIC] = music_player.volume_linear
	volumes[AUDIO_TYPE.UI] = music_player.volume_linear
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.max_polyphony = 10
	
	var i:int = 0
	while 5 > i:
		var new_ap_3d := AudioStreamPlayer3D.new()
		add_child(new_ap_3d)
		position_players.push_back(new_ap_3d)
		i += 1

#TODO Load audio settings from file
func load_from_setting() -> void:
	pass

func set_volume(audio_type:AUDIO_TYPE, amount:float) -> void:
	volumes[audio_type] = amount

func play_audio(new_stream:AudioStream, audio_type:AUDIO_TYPE, pos:Vector3 = Vector3.INF) -> void:
	if pos != Vector3.INF:
		_play_3d_audio(new_stream,audio_type,pos)
		return
	
	audio_player.volume_linear = volumes[audio_type]
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
		
	free_player.volume_linear = volumes[audio_type]
	free_player.stream = new_stream
	free_player.global_position = pos
	free_player.play()
