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
	playback.push_buffer(unpack_mono(packed_frames))

func stereo_to_mono(frames: PackedVector2Array) -> PackedFloat32Array:
	var float_array = PackedFloat32Array()
	float_array.resize(frames.size())
	
	var i: int = 0
	for frame: Vector2 in frames:
		float_array[i] = (frame.x + frame.y) / 2
		i += 1
	
	return float_array

func unpack_mono(packed_frames: PackedFloat32Array) -> PackedVector2Array:
	var frames: PackedVector2Array = PackedVector2Array()
	frames.resize(packed_frames.size())
	
	var i: int = 0
	for packed_frame: float in packed_frames:
		frames[i] = Vector2(packed_frame, packed_frame)
		i += 1
	
	return frames
