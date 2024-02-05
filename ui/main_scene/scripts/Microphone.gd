extends AudioStreamPlayer

var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback

@onready var voip: AudioStreamPlayer = $"../VoIP"

func _ready():
	var idx = AudioServer.get_bus_index("Mic")
	effect = AudioServer.get_bus_effect(idx, 0)
	
	playback = voip.get_stream_playback()

func _process(_delta):
	var frames: PackedVector2Array
	
	if effect.can_get_buffer(1024):
		frames = effect.get_buffer(1024)
		playback_voip.rpc(frames)


@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func playback_voip(frames: PackedVector2Array):
	playback.push_buffer(frames)
