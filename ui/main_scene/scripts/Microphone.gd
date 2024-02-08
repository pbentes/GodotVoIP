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
	
	frames = effect.get_buffer(effect.get_frames_available())
	if frames.size() > 0:
		var mono_frames: PackedFloat32Array = stereo_to_mono(frames)
		playback_voip.rpc(mono_frames)

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func playback_voip(packed_frames: PackedFloat32Array):
	playback.push_buffer(mono_to_stereo(packed_frames))

func stereo_to_mono(stereo_frames: PackedVector2Array) -> PackedFloat32Array:
	var mono_frames = PackedFloat32Array()
	mono_frames.resize(stereo_frames.size())
	
	var i: int = 0
	for stereo_frame: Vector2 in stereo_frames:
		mono_frames[i] = (stereo_frame.x + stereo_frame.y) / 2
		i += 1
	
	return mono_frames

func mono_to_stereo(mono_frames: PackedFloat32Array) -> PackedVector2Array:
	var stereo_frames: PackedVector2Array = PackedVector2Array()
	stereo_frames.resize(mono_frames.size())
	
	var i: int = 0
	for mono_frame: float in mono_frames:
		stereo_frames[i] = Vector2(mono_frame, mono_frame)
		i += 1
	
	return stereo_frames
